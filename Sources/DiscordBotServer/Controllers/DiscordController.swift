
import Vapor
import Discord

struct DiscordController: ChatSession, RouteCollection {
    
    let bot: Bot
    
    init(bot: Bot) {
        self.bot = bot
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("thread", use: thread)
    }
    
    func receive(message: Message) {
        let response = Message.Out(content: "Helper bot is here")
        Task {
            try await bot.send(message: response, channelId: message.channel_id)
        }
    }
    
    func thread(_ req: Request) async throws -> HTTPStatus {
        let channelId = Environment.get("DISCORD_CHANNEL_ID")!
        let channel = try await bot.create(thread: .init(name: "Red Panda"), channelId: channelId)
        try await bot.send(message: .init(content: "Hear me out!"), channelId: channel.id)
        try await bot.subsribe(to: channel.id)
        return .ok
    }
}
