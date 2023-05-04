
import Foundation

extension Gateway {
    
    public struct Intent {
        
        public let rawValue: Int
        
        public static let guilds = Intent(rawValue: 1 << 0)
        public static let guildMembers = Intent(rawValue: 1 << 1)
        public static let guildModeration = Intent(rawValue: 1 << 2)
        public static let guildEmojis = Intent(rawValue: 1 << 3)
        public static let guildIntegrations = Intent(rawValue: 1 << 4)
        public static let guildWebhooks = Intent(rawValue: 1 << 5)
        public static let guildInvites = Intent(rawValue: 1 << 6)
        public static let guildVoiceStates = Intent(rawValue: 1 << 7)
        public static let guildPresences = Intent(rawValue: 1 << 8)
        public static let guildMessages = Intent(rawValue: 1 << 9)
        public static let guildMessageReactions = Intent(rawValue: 1 << 10)
        public static let guildMessageTyping = Intent(rawValue: 1 << 11)
        public static let directMessages = Intent(rawValue: 1 << 12)
        public static let directMessageReactions = Intent(rawValue: 1 << 13)
        public static let directMessageTyping = Intent(rawValue: 1 << 14)
        public static let messageContent = Intent(rawValue: 1 << 15)
        public static let guildScheduledEvents = Intent(rawValue: 1 << 16)
        public static let autoModerationConfigaration = Intent(rawValue: 1 << 20)
        public static let autoModerationEcecution = Intent(rawValue: 1 << 21)
    }
}

extension [Gateway.Intent] {
    
    var combined: Int {
        self.reduce(0) { $0 | $1.rawValue }
    }
    
    static var `default`: Self {
        [
            .guilds,
            .guildMessages,
            .guildMessageReactions,
            .directMessages,
            .directMessageReactions,
        ]
    }
}
