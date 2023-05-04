
import Vapor
import Bots

extension Bot: ChatBot {
    
    public convenience init(app: Application) {
        self.init(app)
        self.gateway.connect()
    }
}

public extension BotID {
    
    static let discord: BotID = .init(rawValue: "discord")
}
