

import Vapor

public struct Message: Codable {
    
    public let channel_id: String
    public let content: String
    public let author: Author
}

public extension Message {
    
    struct Author: Codable {
        
        let id: String
        let username: String
    }
    
    struct Out: Content {
        let content: String
        
        public init(content: String) {
            self.content = content
        }
    }
}

