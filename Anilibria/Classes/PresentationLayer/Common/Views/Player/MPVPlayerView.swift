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
import GLKit

public final class MPVPlayerView: UIView, Player {
    private var secondsRelay: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    private var playRelay: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private var statusRelay: PassthroughSubject<PlayerStatus, Never> = PassthroughSubject()
    private var bag = Set<AnyCancellable>()
    private var observer: Any?
    private let mpvQueue = DispatchQueue(label: "mpv.queue")
    private var mpvContext: OpaquePointer?
    private var mpvGLContext: OpaquePointer?

    private var mpvEventInterceptor: MpvEventInterceptor?
    private var mpvGLUpdatesInterceptor: MpvGLUpdatesInterceptor?

    public private(set) var duration: Double?

    public private(set) var isPlaying: Bool = false {
        didSet {
            if self.isPlaying != oldValue {
                self.playRelay.send(self.isPlaying)
            }
        }
    }

    public var isAirplaySupported: Bool { false }
    public var playerLayer: AVPlayerLayer? { nil }

    private let renderView = MPVRenderView(frame: UIScreen.main.bounds)

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
        checkError(mpv_request_log_messages(mpvContext, "warn"))

        // initializing
        checkError(mpv_set_option_string(mpvContext, "hwdec", "auto"))
        checkError(mpv_initialize(mpvContext))
//        checkError(mpv_set_option_string(mpvContext, "vo", "libmpv"))
        checkError(mpv_set_option_string(mpvContext, "vd-lavc-dr", "no"))
        checkError(mpv_set_option_string(mpvContext, "save-position-on-quit", "no"))
        checkError(mpv_set_option_string(mpvContext, "force-window", "no"))

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
            return CFBundleGetFunctionPointerForName(CFBundleGetBundleWithIdentifier("com.apple.opengles" as CFString), symbolName)
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
            return AnyPublisher<Double?, Error>.just(nil)
        }
        .subscribe(on: mpvQueue)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func set(time: Double) {

    }

    public func togglePlay() {

    }

    deinit {
        _ = try? AVAudioSession.sharedInstance().setActive(false)

        mpv_render_context_set_update_callback(mpvGLContext, nil, nil)
        mpv_render_context_free(mpvGLContext)
        mpv_set_wakeup_callback(mpvContext, nil, nil)
        mpv_destroy(mpvContext)
    }

    private func updateStatus() {

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
        default:
            if let name = mpv_event_name(event.event_id)?.asString {
                print("MPV event: \(name)")
            }
        }
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

    private func makeCommand(_ name: String, args: String...) -> UnsafeMutablePointer<UnsafePointer<CChar>?> {
        let values = [name] + args
        let cs = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: values.count + 1)
        values.enumerated().forEach {
            cs[$0.offset] = UnsafePointer<CChar>(($0.element as NSString).utf8String)
        }
        return cs
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

extension UnsafePointer<CChar> {
    var asString: String {
        String(cString: self)
    }
}

extension String {
    var asUnsafeCString: UnsafePointer<CChar>? {
        let count = self.utf8CString.count
        let result: UnsafeMutableBufferPointer<Int8> = UnsafeMutableBufferPointer<CChar>.allocate(capacity: count)
        _ = result.initialize(from: self.utf8CString)
        return UnsafePointer(result.baseAddress)
    }
}

class MPVRenderView: UIView {
    private let mpvRenderQueue = DispatchQueue(label: "mpv.render.queue", qos: .userInitiated)
    private var context: EAGLContext?
    private var backContext: EAGLContext?

    private var fboName: GLuint = 0
    private var colorRenderbuffer: GLuint = 0
    private var depthRenderbuffer: GLuint = 0

    public override static var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    public var mpvGLContext: OpaquePointer?

    public var glLayer: CAEAGLLayer? {
        if let value = layer as? CAEAGLLayer {
            return value
        }
        return nil
    }

    func create(completion: @escaping () -> Void) {
        self.setup()
        mpvRenderQueue.async { [weak self] in
            guard let context = self?.context else { return }
            self?.backContext = EAGLContext(api: .openGLES3, sharegroup: context.sharegroup)
            EAGLContext.setCurrent(self?.backContext)
            completion()
        }
//        guard let context = self.context else { return }
//        self.backContext = EAGLContext(api: .openGLES3, sharegroup: context.sharegroup)
//        EAGLContext.setCurrent(self.backContext)
//        completion()
    }

    private func setup() {
        guard let context = EAGLContext(api: .openGLES3) else { return }
        self.context = context

        glLayer?.isOpaque = true
//        glLayer?.contentsScale = UIScreen.main.scale
        glLayer?.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: NSNumber(false),
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]

        EAGLContext.setCurrent(context)

        glGenFramebuffers(1, &fboName)
        glGenRenderbuffers(1, &colorRenderbuffer)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fboName)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)

        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.glLayer)

        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderbuffer)

        // Get the drawable buffer's width and height so we can create a depth buffer for the FBO
//        var backingWidth: GLint = 0
//        var backingHeight: GLint = 0
//        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &backingWidth)
//        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &backingHeight)
//
//        glGenRenderbuffers(1, &depthRenderbuffer)
//        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderbuffer)
//        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), backingWidth, backingHeight)
//        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderbuffer)

        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GL_FRAMEBUFFER_COMPLETE {
            preconditionFailure("failed to make complete framebuffer object \(status)")
        }
    }

//    private func setupBuffers() {
//        glDisable(GLenum(GL_DEPTH_TEST))
//
//        glEnableVertexAttribArray()
//        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
//
//        glEnableVertexAttribArray(ATTRIB_TEXCOORD);
//        glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
//
//        glGenFramebuffers(1, &_frameBufferHandle);
//        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//
//        glGenRenderbuffers(1, &_colorBufferHandle);
//        glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//
//        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
//        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
//        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
//
//        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
//        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
//            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//        }
//    }

    func draw() {
        let w =  Int32(self.frame.width * self.contentScaleFactor)
        let h = Int32(self.frame.height * self.contentScaleFactor)
        mpvRenderQueue.async { [weak self] in
            if let self = self {
                self.render(w: w, h: h)
            }
        }
//        self.render(w: w, h: h)
    }

    private func render(w: Int32, h: Int32) {
        EAGLContext.setCurrent(self.backContext)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fboName)

        if let mpvGLContext = self.mpvGLContext {

            var openglFbo = mpv_opengl_fbo(fbo: Int32(fboName), w: w, h: h, internal_format: 0)
            let openglFboPoniter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: &openglFbo) { $0 })
            let flipYponiter = UnsafeMutableRawPointer(mutating: withUnsafePointer(to: 1) { $0 })

            var params = [
                mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: openglFboPoniter),
                mpv_render_param(type: MPV_RENDER_PARAM_FLIP_Y, data: flipYponiter),
                mpv_render_param()
            ]
            mpv_render_context_render(mpvGLContext, &params)
            glFlush()
        } else {
            fillBlack()
        }

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        backContext?.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    private func fillBlack() {
        let random: GLfloat = [0.1, 0.3 ,0.5 ,0.7, 1].randomElement()!
        glClearColor(0, random, 0, 0)
        glClear(UInt32(GL_COLOR_BUFFER_BIT))
    }

    deinit {
        glDeleteFramebuffers(1, &fboName)
        glDeleteRenderbuffers(1, &colorRenderbuffer)
        glDeleteRenderbuffers(1, &depthRenderbuffer)
        EAGLContext.setCurrent(nil)
    }
}
