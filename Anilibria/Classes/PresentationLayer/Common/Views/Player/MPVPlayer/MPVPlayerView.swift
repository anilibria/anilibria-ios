//
//  MPVPlayerView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.01.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation
import Combine
import AVKit
import libmpv

public final class MPVPlayerView: UIView, Player {
    private var secondsRelay: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private var playRelay: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var statusRelay: PassthroughSubject<PlayerStatus, Never> = PassthroughSubject()
    private var durationRelay: PassthroughSubject<Double?, Error> = PassthroughSubject()
    private var bag = Set<AnyCancellable>()
    private var observer: Any?
    private let mpvQueue = DispatchQueue(label: "mpv.queue")
    private var mpvContext: OpaquePointer?
    private var mpvGLContext: OpaquePointer?

    private var mpvEventInterceptor: MpvEventInterceptor?
    private var mpvGLUpdatesInterceptor: MpvGLUpdatesInterceptor?

    public private(set) var duration: Double?
    public private(set) var audioTracks: [AudioTrack] = []
    public private(set) var currentAudio: AudioTrack?
    public private(set) var subtitles: [Subtitles] = []
    public private(set) var currentSubtitles: Subtitles?

    public private(set) var isPlaying: Bool = false {
        didSet {
            if self.isPlaying != oldValue {
                self.playRelay.send(self.isPlaying)
            }
        }
    }

    public var isAirplaySupported: Bool { false }
    public var playerLayer: AVPlayerLayer? { nil }

    private let renderView = MPVRenderView(frame: .init(origin: .zero, size: UIApplication.keyWindowSize))

    public override init(frame: CGRect) {
        super.init(frame: frame)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        setupPlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer() {
        isUserInteractionEnabled = false
        addSubview(renderView)
        renderView.constraintEdgesToSuperview()
        initializeMpv()
    }

    private func initializeMpv() {
        mpvContext = mpv_create()

        if mpvContext == nil {
            preconditionFailure("initialization failed")
        }

        mpvEventInterceptor = MpvEventInterceptor(context: mpvContext, queue: mpvQueue) { [weak self] in
            self?.handle(event: $0)
        }

        // logging
        // checkError(mpv_request_log_messages(mpvContext, "warn"))
        checkError(mpv_request_log_messages(mpvContext, "v"))

        // initializing
        checkError(mpv_set_option_string(mpvContext, "hwdec", "no"))
        checkError(mpv_initialize(mpvContext))
        checkError(mpv_set_option_string(mpvContext, "vo", "libmpv"))
        checkError(mpv_set_option_string(mpvContext, "vd-lavc-dr", "no"))
        checkError(mpv_set_option_string(mpvContext, "save-position-on-quit", "no"))
        checkError(mpv_set_option_string(mpvContext, "force-window", "no"))
        checkError(mpv_set_option_string(mpvContext, "pause", "yes"))

        // configure
        renderView.create { [weak self] in
            self?.setupRender()
        }

        mpvQueue.async { [weak self] in
            self?.setupMPVCallbacks()
        }
    }

    private func setupMPVCallbacks() {
        mpv_set_wakeup_callback(mpvContext, { pointer in
            pointer?.assumingMemoryBound(to: MpvEventInterceptor.self).pointee.wakeup()
        }, &mpvEventInterceptor)
    }

    private func setupRender() {
        let openGLApi = UnsafeMutableRawPointer(mutating: MPV_RENDER_API_TYPE_OPENGL.asUnsafeCString)

        var initOpenGL = mpv_opengl_init_params(get_proc_address: { _, name in
            let symbolName = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII)
            #if targetEnvironment(macCatalyst)
            let renderID = "com.apple.opengl" as CFString
            #else
            let renderID = "com.apple.opengles" as CFString
            #endif
            
            return CFBundleGetFunctionPointerForName(
                CFBundleGetBundleWithIdentifier(CFStringCreateCopy(kCFAllocatorDefault, renderID)),
                symbolName
            )
        }, get_proc_address_ctx: nil)

        let initOpenGLPoniter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: &initOpenGL) { $0 })

        var params = [
            mpv_render_param(type: MPV_RENDER_PARAM_API_TYPE, data: openGLApi),
            mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, data: initOpenGLPoniter),
            mpv_render_param(type: MPV_RENDER_PARAM_INVALID, data: nil)
        ]

        mpv_render_context_create(&mpvGLContext, mpvContext, &params)
        renderView.mpvGLContext = mpvGLContext

        mpvGLUpdatesInterceptor = MpvGLUpdatesInterceptor { [weak self] in
            self?.renderView.draw()
        }

        mpv_render_context_set_update_callback(mpvGLContext, { pointer in
            pointer?.assumingMemoryBound(to: MpvGLUpdatesInterceptor.self).pointee.needsUpdate()
        }, &mpvGLUpdatesInterceptor)
    }

    public func getCurrentTime() -> AnyPublisher<Double, Never> {
        return self.secondsRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getPlayChanges() -> AnyPublisher<Bool, Never> {
        return self.playRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func getStatusSequence() -> AnyPublisher<PlayerStatus, Never> {
        return self.statusRelay
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func setVideo(url: URL) -> AnyPublisher<Double?, Error> {
        self.isPlaying = false
        self.duration = nil
        self.statusRelay.send(.unknown)

        return Deferred { [weak self] () -> AnyPublisher<Double?, Error> in
            guard let self = self else { return AnyPublisher<Double?, Error>.just(nil) }
            self.checkError(mpv_command(self.mpvContext, self.makeCommand("loadfile", args: url.absoluteString)))
            return self.durationRelay.eraseToAnyPublisher()
        }
        .subscribe(on: mpvQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func set(time: Double) {
        print("\(time)")
        
        statusRelay.send(.waitingToPlay)
        checkError(mpv_command(mpvContext, makeCommand("seek", args: "\(Int(time))", "absolute")))
        if isPlaying {
            statusRelay.send(.playing)
        } else {
            statusRelay.send(.radyToPlay)
        }
    }
    
    public func set(subtitle: Subtitles) {
        if currentSubtitles != subtitle, subtitles.contains(where: { subtitle.id == $0.id }) {
            checkError(mpv_set_option_string(mpvContext, "sid", subtitle.id))
            currentSubtitles = subtitle
        }
    }
    
    public func set(audio: AudioTrack) {
        if currentAudio != audio, audioTracks.contains(where: { audio.id == $0.id }) {
            checkError(mpv_set_option_string(mpvContext, "aid", audio.id))
            currentAudio = audio
        }
    }

    public func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            checkError(mpv_set_option_string(mpvContext, "pause", "no"))
            statusRelay.send(.playing)
        } else {
            checkError(mpv_set_option_string(mpvContext, "pause", "yes"))
            statusRelay.send(.pause)
        }
    }

    deinit {
        _ = try? AVAudioSession.sharedInstance().setActive(false)

        mpv_render_context_set_update_callback(mpvGLContext, nil, nil)
        mpv_render_context_free(mpvGLContext)
        mpv_set_wakeup_callback(mpvContext, nil, nil)
        mpv_destroy(mpvContext)
    }

    private func handle(event: mpv_event) {
        switch event.event_id {
        case MPV_EVENT_SHUTDOWN:
            mpv_destroy(mpvContext)
            mpvContext = nil
            print("MPV event: shutdown")
        case MPV_EVENT_LOG_MESSAGE:
            let msg = event.data.load(as: mpv_event_log_message.self)
            print("MPV event: [\(msg.prefix.asString)] \(msg.level.asString): \(msg.text.asString)")
        case MPV_EVENT_PROPERTY_CHANGE:
            let property = event.data.load(as: mpv_event_property.self)
            
            if property.name.asString == "time-pos", let time = property.data?.load(as: Int64.self) {
                DispatchQueue.main.async { [weak self] in
                    self?.secondsRelay.send(Double(time))
                }
            }
            
        case MPV_EVENT_FILE_LOADED:
            let duration = getPropertyNumber("duration")
            checkError(mpv_observe_property(self.mpvContext, 0, "time-pos", MPV_FORMAT_INT64))
            makeTracks()
            self.duration = Double(duration)
            
            DispatchQueue.main.async { [weak self] in
                self?.durationRelay.send(self?.duration)
                self?.statusRelay.send(.radyToPlay)
            }
        default:
            if let name = mpv_event_name(event.event_id)?.asString {
                print("MPV event: \(name)")
            }
        }
    }
    
    func makeTracks() {
        let count = getPropertyNumber("track-list/count")
        
        for i in 0..<count {
            let id = getPropertyNumber("track-list/\(i)/id")
            let type = String(cString: getPropertyNode("track-list/\(i)/type").u.string)
            let title = String(cString: getPropertyNode("track-list/\(i)/title").u.string)
            let selected = getPropertyNode("track-list/\(i)/selected").u.flag
            
            switch type {
            case "audio":
                audioTracks.append(AudioTrack(id: "\(id)", title: title))
                if selected == 1 {
                    currentAudio = audioTracks.last
                }
            case "sub":
                subtitles.append(Subtitles(id: "\(id)", title: title))
                if selected == 1 {
                    currentSubtitles = subtitles.last
                }
            default:
                break
            }
            
            print("type: \(type) id: \(id) title: \(title)")
        }
    }
    
    private func getPropertyNumber(_ name: String) -> Int64 {
        var value = Int64()
        checkError(mpv_get_property(mpvContext, name, MPV_FORMAT_INT64, &value))
        return value
    }
    
    private func getPropertyNode(_ name: String) -> mpv_node {
        var value = mpv_node()
        checkError(mpv_get_property(mpvContext, name, MPV_FORMAT_NODE, &value))
        return value
    }

    private func checkError(_ status: Int32) {
        if status < 0 {
            var message = "unknown"
            if let cString = mpv_error_string(status)?.asString {
                message = cString
            }

            preconditionFailure(message)
        }
    }
    
    private func makeCommand(_ name: String, args: [String] = []) -> UnsafeMutablePointer<UnsafePointer<CChar>?> {
        let values = [name] + args + [nil]
        let cs = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: values.count)
        values.enumerated().forEach {
            cs[$0.offset] = UnsafePointer<CChar>(($0.element as? NSString)?.utf8String)
        }
        return cs
    }

    private func makeCommand(_ name: String, args: String...) -> UnsafeMutablePointer<UnsafePointer<CChar>?> {
       makeCommand(name, args: args)
    }
}

private class MpvEventInterceptor: NSObject {
    private let queue: DispatchQueue
    private var mpvContext: OpaquePointer?
    private let eventHandler: (mpv_event) -> Void

    init(context: OpaquePointer?, queue: DispatchQueue, eventHandler: @escaping (mpv_event) -> Void) {
        self.mpvContext = context
        self.queue = queue
        self.eventHandler = eventHandler
    }

    func wakeup() {
        queue.async { [weak self] in self?.readEvent() }
    }

    private func readEvent() {
        while mpvContext != nil {
            guard let event = mpv_wait_event(mpvContext, 0)?.pointee else {
                break
            }

            if event.event_id == MPV_EVENT_NONE {
                break
            }
            eventHandler(event)
        }
    }
}

private class MpvGLUpdatesInterceptor: NSObject {
    private let actionHandler: () -> Void

    init(actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
    }

    func needsUpdate() {
        DispatchQueue.main.async { [weak self] in self?.actionHandler() }
    }
}
