
import Vapor

public protocol Chat {
    
    init(bot: Bot)
    var bot: Bot { get }
    func receive(message: Message)
}
