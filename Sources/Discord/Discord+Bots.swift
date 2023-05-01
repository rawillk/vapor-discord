
import Vapor
import Bots

extension Bot: ChatBot {
    
    public convenience init(app: Application) {
        self.init(client: app.client, provider: .shared(app.eventLoopGroup))
    }
}

public extension BotID {
    
    static let discord: BotID = .init(rawValue: "discord")
}
