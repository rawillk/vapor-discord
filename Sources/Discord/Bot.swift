
import Vapor

public final class Bot {
    
    public let app: Application
    public var client: Client { app.client }
    public var logger: Logger { app.logger }
    public let gateway: Gateway
    
    private let api: API = .init()
    private let eventLoopGroup: EventLoopGroup
    private var chats: [any ChatSession] = []
    
    private var headers: HTTPHeaders {
        ["Authorization": "Bot \(gateway.token)"]
    }
    
    public init(
        _ app: Application,
        factory: @escaping (Bot) -> [any ChatSession] = {_ in []}
    ) {
        self.app = app
        self.eventLoopGroup = app.eventLoopGroup
        self.gateway = .init(logger: app.logger, eventLoopGroup: app.eventLoopGroup)
        chats = factory(self)
        gateway.wss = getWss
        gateway.onMessage = { [unowned self] message in
            chats.forEach { chat in
                chat.receive(message: message)
            }
        }
    }
    
    private func getWss() async throws -> String {
        let result = try await client.get(api.gateway, headers: headers)
        let wss = try result.content.decode(Gateway.WSS.self)
        return api.wss(wss.url)
    }
    
    public func register(_ facrory: @escaping (Bot) -> some ChatSession) {
        chats.append(facrory(self))
    }
    
    @discardableResult
    public func register<C: ChatSession>(_ chat: C.Type) -> C {
        let chat = C.init(bot: self)
        chats.append(chat)
        return chat
    }
    
    public func send(message: Message.Out, channelId: String) async throws {
        let _ = try await client.post(api.messages(channelId), headers: headers, content: message)
    }
    
    public func create(thread: Thread, channelId: String) async throws -> Channel {
        let response = try await client.post(api.threads(channelId), headers: headers, content: thread)
        return try response.content.decode(Channel.self)
    }
    
    public func subsribe(member: String = "@me", to channel: String) async throws {
        let _ = try await client.put(api.thread(member: member, channel), headers: headers)
    }
}

extension ClientResponse {
    func printBody() {
        if let body {
            let string = String(buffer: body)
            print(string)
        }
    }
}
