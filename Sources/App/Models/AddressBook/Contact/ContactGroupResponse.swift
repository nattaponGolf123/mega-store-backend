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

    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        let dateFormat = Date.Format.iso8601
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)?.tryToDate(dateFormat)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)?.tryToDate(dateFormat)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)?.tryToDate(dateFormat)
    }

    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.description, forKey: .description)
        let dateFormat = Date.Format.iso8601
        try container.encode(self.createdAt?.toDateString(dateFormat), forKey: .createdAt)
        try container.encode(self.updatedAt?.toDateString(dateFormat), forKey: .updatedAt)
        try container.encode(self.deletedAt?.toDateString(dateFormat), forKey: .deletedAt)
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
