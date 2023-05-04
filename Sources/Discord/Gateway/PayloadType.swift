
import Foundation

extension Gateway {
    
    enum PayloadType: String, Codable {
        
        case guildCreate = "GUILD_CREATE"
        case messageCreate = "MESSAGE_CREATE"
        case messageUpdate = "MESSAGE_UPDATE"
        case channelCreate = "CHANNEL_CREATE"
        case threadCreate = "THREAD_CREATE"
        case ready = "READY"
    }
}
