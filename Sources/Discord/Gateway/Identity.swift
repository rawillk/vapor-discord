
import Foundation

extension Gateway {
    
    struct Identity: Codable {
        
        let token: String
        let intents: Int
        let properties: [String: String]
        
        init(
            token: String,
            intents: [Intent],
            properties: [String : String] = ["$os": "macOS","$browser": "Vapor", "$device": "Server"]
        ) {
            self.token = token
            self.intents = intents.combined
            self.properties = properties
        }
    }
}
