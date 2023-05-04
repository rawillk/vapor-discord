

import Vapor

struct API {
    
    let baseURL: String = "https://discord.com/api/v10"
    
    var gateway: URI {
        .init(string: baseURL + "/gateway/bot")
    }
    
    func messages(_ channelId: String) -> URI {
        .init(string: baseURL + "/channels/\(channelId)/messages")
    }
    
    func wss(_ base: String) -> String {
        base + "?v=10&encoding=json"
    }
    
    func threads(_ channelId: String) -> URI {
        .init(string: baseURL + "/channels/\(channelId)/threads")
    }
    
    func thread(member: String = "@me", _ channelId: String) -> URI {
        .init(string: baseURL + "/channels/\(channelId)/thread-members/" + member )
    }
}
