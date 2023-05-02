
import Vapor
import Bots

extension Bot: ChatBot {
    
    public convenience init(app: Application) {
        self.init(app)
    }
}

public extension BotID {
    
    static let discord: BotID = .init(rawValue: "discord")
}
