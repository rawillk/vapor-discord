
import Vapor

public final class Bot {
    
    let client: Client
    var socket: WebSocket?
    
    private let token = Environment.get("DISCORD_API_TOKEN")!
    private let appID = Environment.get("DISCORD_APP_ID")!
    
    private let api: API = .init()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let eventLoopGroup: EventLoopGroup
    private var chats: [any Chat] = []
    
    private var headers: HTTPHeaders {
        ["Authorization": "Bot \(token)"]
    }
    
    public init(
        client: Client,
        provider: Application.EventLoopGroupProvider = .createNew,
        factory: @escaping (Bot) -> [any Chat] = {_ in []}
    ) {
        self.client = client
        switch provider {
        case .createNew:
            eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        case .shared(let group):
            eventLoopGroup = group
        }
        chats = factory(self)
        startServer()
    }
    
    deinit {
        _ = socket?.close()
    }
    
    public func register(_ facrory: @escaping (Bot) -> some Chat) {
        chats.append(facrory(self))
    }
    
    @discardableResult
    public func register<C: Chat>(_ chat: C.Type) -> C {
        let chat = C.init(bot: self)
        chats.append(chat)
        return chat
    }
    
    private func startServer() {
        Task {
            do {
                let result = try await client.get(api.gateway, headers: headers)
                let gat = try result.content.decode(Gateway.self)
                try await WebSocket.connect(to: api.wss(gat.url), on: eventLoopGroup.next()) { [unowned self] ws in
                    listen(socket: ws)
                }
            } catch {
                print(error)
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
            print(error)
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
            print(error)
            print(message)
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
            chats.forEach { chat in
                chat.receive(message: message)
            }
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
            send(json: Identity(token: token), opcode: .identify)
        case .heartbitACK:
            print("heartbit")
        }
    }
    
    public func send(message: Message.Out, channelId: String) async throws {
        let _ = try await client.post(api.messages(channelId), headers: headers, content: message)
    }
}
