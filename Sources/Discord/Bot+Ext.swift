

import Vapor

extension Bot {
    
    struct Gateway: Content {
        let url: String
    }
    
    struct Payload<D: Codable>: Codable {
        let op: Opcode
        let t: PayloadType?
        let d: D
    }
    
    struct Status: Decodable {
        let op: Opcode
        let t: PayloadType?
    }
    
    struct Hello: Codable {
        let heartbeat_interval: Int64
    }
    
    struct Identity: Codable {
        let token: String
        let intents: Int
        let properties: [String: String]
        
        init(token: String, intents: Int = 4608, properties: [String : String] = ["$os": "macOS","$browser": "Vapor", "$device": "Server"]) {
            self.token = token
            self.intents = intents
            self.properties = properties
        }
    }
    
    enum Opcode: Int, Codable {
        
        case dispatch = 0
        case heartbit = 1
        case identify = 2
        case presenceUpdate = 3
        case voiceStateUpdate = 4
        case resume = 6
        case reconnect = 7
        case requestGuildMembers = 8
        case invalidSession = 9
        case hello = 10
        case heartbitACK = 11
    }
    
    enum PayloadType: String, Codable {
        case messageCreate = "MESSAGE_CREATE"
        case channelCreate = "CHANNEL_CREATE"
        case ready = "READY"
    }
    
    struct Key: StorageKey {
        public typealias Value = Bot
    }
    
    enum Failure: Error {
        
        case noHandler(Opcode)
    }
}


