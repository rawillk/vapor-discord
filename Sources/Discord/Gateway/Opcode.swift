
import Foundation

extension Gateway {
    
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
}
