
import Vapor
import Discord

struct DiscordController: Chat {
    
    let bot: Bot
    
    init(bot: Bot) {
        self.bot = bot
    }
    
    func receive(message: Message) {
        let response = Message.Out(content: "Helper bot is here")
        Task {
            try await bot.send(message: response, channelId: message.channel_id)
        }
    }
}
