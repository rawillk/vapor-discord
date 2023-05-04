
import Vapor
import Discord

// configures your application
public func configure(_ app: Application) async throws {
    
    let bot = app.bots.use(Discord.Bot.self, as: .discord)
    let controller = bot.register(DiscordController.self)
    
    try app.register(collection: controller)
    
    try routes(app)
}
