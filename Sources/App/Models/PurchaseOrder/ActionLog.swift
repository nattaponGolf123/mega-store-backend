import Foundation
import Vapor
import Fluent

struct ActionLog: Content {
    let userId: UUID
    let action: Action
    let date: Date
}

extension ActionLog {
    enum Action: String, Codable {
        case created = "CREATED"
        case updated = "UPDATED"
        case deleted = "DELETED"
        case approved = "APPROVED"        
        case voided = "VOIDED"
    }
}
