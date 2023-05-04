//
//  File.swift
//  
//
//  Created by Ravil Khusainov on 04.05.2023.
//

import Vapor

public final class Gateway {
    
    typealias Event = PayloadType
    
    var wss: () async throws -> (String) = { throw Failure.wssEndpointNotReceived }
    var onMessage: (Message) -> Void = {_ in}
    let logger: Logger
    let eventLoopGroup: EventLoopGroup
    
    init(logger: Logger, eventLoopGroup: EventLoopGroup) {
        self.logger = logger
        self.eventLoopGroup = eventLoopGroup
    }
    
    let token = Environment.get("DISCORD_API_TOKEN")!
    let appID = Environment.get("DISCORD_APP_ID")!
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var intents: [Intent] = []
    private var subscriptions: [PayloadType: any Sub] = [:]
    private var socket: WebSocket?
    
    func connect(with intents: [Intent] = .default) {
        self.intents = intents
        Task {
            do {
                let url = try await wss()
                try await WebSocket.connect(to: url, on: eventLoopGroup.next()) { [unowned self] ws in
                    listen(socket: ws)
                }
            } catch {
                logger.log(level: .error, .init(stringLiteral: error.localizedDescription))
            }
        }
    }
    
    private func listen(socket: WebSocket) {
        self.socket = socket
        socket.onText { [unowned self] ws, text in
            handle(message: text)
        }
    }
    
    private func scheduleHeartbeat(interval: Int64) {
        eventLoopGroup.next().scheduleRepeatedTask(initialDelay: .zero, delay: .milliseconds(interval)) { [unowned self] task in
            if let socket, socket.isClosed {
                task.cancel()
            } else {
                send(.heartbit)
            }
        }
    }
    
    private func send<D: Codable>(json: D, opcode: Opcode) {
        let payload = Payload(op: opcode, t: nil, d: json)
        do {
            let data = try encoder.encode(payload)
            socket?.send(raw: data, opcode: .binary)
        } catch {
            logger.log(level: .error, .init(stringLiteral: error.localizedDescription))
        }
    }
    
    private func send(_ opcode: Opcode) {
        let string = "{\"op\":\(opcode.rawValue),\"d\":null}"
        socket?.send(string)
    }
    
    private func handle(message: String) {
        guard let data = message.data(using: .utf8) else { return }
        do {
            let status = try decoder.decode(Status.self, from: data)
            try handle(status: status, data: data)
        } catch {
            logger.log(level: .error, .init(stringLiteral: error.localizedDescription))
            logger.log(level: .debug, .init(stringLiteral: message))
        }
    }
    
    private func unwrap<D: Codable>(_ data: Data) throws -> D {
        let payload = try decoder.decode(Payload<D>.self, from: data)
        return payload.d
    }
    
    private func handle(status: Status, data: Data) throws {
        let opcode = status.op
        switch status.op {
        case .dispatch where status.t == .messageCreate:
            let message: Message = try unwrap(data)
            guard message.author.id != appID else { return }
            onMessage(message)
            notify(.messageCreate, value: message)
        case .dispatch where status.t == .ready:
            logger.log(level: .info, "Discord Bot: Identity accepted")
        case .dispatch where status.t == .threadCreate:
            logger.log(level: .info, "Discord Bot: Thread created")
        case .dispatch where status.t == .guildCreate:
            logger.log(level: .info, "Discord Bot: Guild created")
        case .dispatch:
            throw Failure.noHandler(opcode)
        case .heartbit:
            send(.heartbit)
        case .identify:
            throw Failure.noHandler(opcode)
        case .presenceUpdate:
            throw Failure.noHandler(opcode)
        case .voiceStateUpdate:
            throw Failure.noHandler(opcode)
        case .resume:
            throw Failure.noHandler(opcode)
        case .reconnect:
            throw Failure.noHandler(opcode)
        case .requestGuildMembers:
            throw Failure.noHandler(opcode)
        case .invalidSession:
            throw Failure.noHandler(opcode)
        case .hello:
            let payload = try decoder.decode(Payload<Hello>.self, from: data)
            scheduleHeartbeat(interval: payload.d.heartbeat_interval)
            send(json: Identity(token: token, intents: intents), opcode: .identify)
        case .heartbitACK:
            logger.log(level: .info, "Discord Bot: Heartbit")
        }
    }
    
    func on<Value>(_ payloadType: PayloadType, callback: @escaping (Value) -> Void) {
        subscriptions[payloadType] = Subscriber(send: callback)
    }
    
    private func notify<Value>(_ payloadType: PayloadType, value: Value) {
        guard let sub = subscriptions[payloadType] as? Subscriber<Value> else { return }
        sub.send(value)
    }
    
    struct Subscriber<Value>: Sub {
        let send: (Value) -> Void
    }
    
    struct Payload<D: Codable>: Codable {
        let op: Opcode
        let t: PayloadType?
        let d: D
    }
    
    struct Status: Decodable {
        let op: Opcode
        let t: PayloadType?
    }
    
    struct Hello: Codable {
        let heartbeat_interval: Int64
    }
    
    struct WSS: Codable {
        let url: String
    }
    
    enum Failure: Error {
        
        case noHandler(Opcode)
        case wssEndpointNotReceived
    }
}

private protocol Sub<Value> {
    associatedtype Value
    var send: (Value) -> Void { get }
}
