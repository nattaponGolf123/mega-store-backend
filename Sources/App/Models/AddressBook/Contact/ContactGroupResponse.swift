//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ContactGroupResponse: Content {
    let id: UUID?
    let name: String
    let description: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from: ContactGroup) {
        self.id = from.id
        self.name = from.name
        self.description = from.description
        self.createdAt = from.createdAt
        self.updatedAt = from.updatedAt
        self.deletedAt = from.deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

}
