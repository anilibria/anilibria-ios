//
//  PeerClient.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Network
import Combine

enum PeerClientState {
    case initial
    case ready
    case stopped
    case broken
}

class PeerClient: NSObject, StreamDelegate, Loggable {
    var defaultLoggingTag: LogTag { .model }
    
    private let torrent: TorrentData
    private var connection: NWConnection?
    private let queue: DispatchQueue
    private var piceProgress: PieceProgress?
    private let workQueue: WorkQueue
    private var waitForPiece: AnyCancellable?
    private var timeoutHolder: DelayedAction?

    private(set) var isChocked = true
    private(set) var isDownloading = false
    private(set) var bitfield = Bitfield()
    private var failedPieces = Set<Int>()
    let peer: Peer

    @Published private(set) var state: PeerClientState = .initial {
        didSet {
            if state == .stopped || state == .broken {
                if let piece = self.piceProgress?.piece, self.piceProgress?.isCompleted == false {
                    if connection?.state == .ready {
                        connection?.cancel()
                    }
                    self.piceProgress = nil
                    self.waitForPiece = nil
                    workQueue.insert(piece)
                    log(.verbose, "==> Client \(self.peer.ip): return -- Piece [\(piece)]")
                }
            }
        }
    }

    init?(torrent: TorrentData, peer: Peer, workQueue: WorkQueue) {
        self.torrent = torrent
        self.peer = peer
        self.workQueue = workQueue
        self.queue = DispatchQueue(label: "peer.queue.\(peer.ip.hashValue)")
        super.init()
        self.start()
    }
    
    private func start() {
        guard let ip = IPv4Address(peer.ip), let port = NWEndpoint.Port(rawValue: peer.port) else {
            self.state = .broken
            return
        }
        
        log(.verbose, "Connecting to: \(peer.ip)")
        let tcp = NWProtocolTCP.Options()
        tcp.noDelay = true
        let params = NWParameters(tls: nil, tcp: tcp)
        self.connection = NWConnection(host: .ipv4(ip), port: port, using: params)
        self.run()
    }

    private func run() {
        self.receive()
        connection?.stateUpdateHandler = { [weak self] (newState) in
            guard let self = self else { return }
            switch newState {
            case .ready:
                self.sendHandshake()
            case .failed:
                self.state = .stopped
            default:
                break
            }
        }
        connection?.start(queue: queue)
    }

    private func processedMessage(_ data: Data) {
        switch state {
        case .initial:
            if case let (handshake?, leftBytes) = Handshake.make(from: data), handshake.infoHash == torrent.infoHash {
                state = .ready
                send(message: .init(id: .unchoke))
                send(message: .init(id: .interested))
                if !leftBytes.isEmpty {
                    try? readMessage(leftBytes)
                }
            } else {
                state = .stopped
            }
        case .ready:
            try? readMessage([UInt8](data))
        case .stopped, .broken:
            break
        }
    }

    private func receive() {
        timeoutHolder = DelayedAction(delay: 10) { [weak self] in
            guard let self = self else { return }
            log(.verbose, "== \(self.peer.ip) - receive timeout")
            self.state = .stopped
        }
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self?.processedMessage(data)
            }
            if isComplete || error != nil {
                self?.state = .stopped
            } else {
                self?.receive()
            }
        }
    }

    private func sendHandshake() {
        connection?.send(content: Handshake(torrent).makeData(), completion: .contentProcessed({ [weak self] error in
            if error != nil { self?.state = .stopped }
        }))
    }

    private func send(message: PeerMessage) {
        connection?.send(content: message.makeData(), completion: .contentProcessed({ [weak self] error in
            if error != nil { self?.state = .stopped }
        }))
    }

    private var msgBuffer: PeerMessage?
    private var unusedBytes: [UInt8]?

    private func readMessage(_ dataBytes: [UInt8]) throws {
        let data: [UInt8]
        if let unusedBytes = self.unusedBytes {
            data = unusedBytes + dataBytes
            self.unusedBytes = nil
        } else {
            data = dataBytes
        }

        if var msgBuffer = msgBuffer {
            let left = msgBuffer.add(bytes: data)
            try handle(msgBuffer, leftBytes: left)
            return
        }

        let (message, leftBytes) = PeerMessage.make(from: data)

        guard let msg = message else {
            if data == keepAlive {
                log(.verbose, "-- \(self.peer.ip) - Message: keep-alive")
            } else if data.count < 5 {
                self.unusedBytes = data
            } else {
                log(.verbose, "-- \(self.peer.ip) - Message: UNKNOWN(\(data.count))")
            }
            return
        }

        try handle(msg, leftBytes: leftBytes)
    }

    private func handle(_ msg: PeerMessage, leftBytes: [UInt8]?) throws {
        if msg.lackOfData {
            msgBuffer = msg
            return
        }
        msgBuffer = nil
        if let piece = piceProgress?.piece { log(.verbose, "-- \(self.peer.ip) - Message: \(msg.id) [\(piece)]") }

        process(msg)

        if let next = leftBytes {
            try readMessage(next)
        }
    }

    private func process(_ msg: PeerMessage) {
        switch msg.id {
        case .bitfield:
            self.bitfield = Bitfield(data: msg.payload)
        case .unchoke:
            self.isChocked = false
            self.piceProgress?.run(isChocked)
            self.download()
        case .choke:
            self.isChocked = true
            self.piceProgress?.run(isChocked)
        case .have:
            if let index = UInt32(msg.payload)?.byteSwapped {
                self.bitfield.setPiece(index: index)
            }
        case .piece:
            piceProgress?.update(with: msg, isChocked: isChocked)
        default:
            break
        }
    }

    private func download() {
        if state != .ready || bitfield.isEmpty || isDownloading {
            return
        }
        waitForPiece = nil
        isDownloading = true

        let isIntersects = workQueue.getBitfield().intersects(bitfield)
        if isIntersects, let piece = workQueue.next() {
            download(piece: piece)
        } else {
            isDownloading = false
            log(.verbose, "== \(self.peer.ip) - waitForPiece intersects: \(isIntersects)")
            waitForPiece = workQueue.pieceReturned.first().sink(receiveValue: { [weak self] in
                self?.download()
            })
        }
    }

    private func download(piece: PieceWork) {
        var piece = piece
        while !bitfield.hasPiece(index: piece.index) || failedPieces.contains(piece.index) {
            if let pw = workQueue.exchange(piece) {
                piece = pw
            } else {
                self.state = .stopped
                return
            }
        }

        self.attemptDownload(piece: piece)
    }

    private func attemptDownload(piece: PieceWork) {
        piceProgress = PieceProgress(piece: piece)
        piceProgress?.setSender({ [weak self] in self?.send(message: $0)  })
        piceProgress?.setTimeout({ [weak self] in
            guard let self = self else { return }
            failedPieces.insert(piece.index)
            self.download(piece: piece)
            log(.verbose, "== Client \(self.peer.ip): return -- Piece [\(piece)]")
        })
        piceProgress?.didComplete({ [weak self] (result) in
            if result.checkIntegrity() {
                self?.workQueue.set(result: result)
            } else {
                var item = result
                item.reset()
                self?.workQueue.insert(item)
            }
            self?.isDownloading = false
            self?.piceProgress = nil
            self?.download()
        })

        piceProgress?.run(isChocked)
    }
}
