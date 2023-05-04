
import Vapor

public protocol ChatSession {
    
    init(bot: Bot)
    func receive(message: Message)
}
