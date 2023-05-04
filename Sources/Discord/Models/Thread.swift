
import Vapor

public struct Thread: Content {
    
    public let name: String
    public let type: ChannelType
    
    public init(name: String, type: ChannelType = .publicThread) {
        self.name = name
        self.type = type
    }
}
