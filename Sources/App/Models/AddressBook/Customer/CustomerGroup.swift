//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class CustomerGroup: Model, Content {
    static let schema = "CustomerGroups"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String?
    
    @Timestamp(key: "created_at",
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         name: String,
         description: String? = nil,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.name = name
        self.description = description
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension CustomerGroup {
    struct Create: Content, Validatable {
        let name: String
        let description: String?
        
        init(name: String,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                     forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        
        init(name: String? = nil,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
}

extension CustomerGroup {
    struct Stub {
        
        static var group: [CustomerGroup] {
            [
                .init(name: "Retail",
                      description: "Retail customers"),
                .init(name: "Wholesale",
                      description: "Wholesale customers"),
                .init(name: "Distributor",
                      description: "Distributor customers"),
            ]
        }
        
        static var retail: CustomerGroup {
            .init(name: "Retail",
                  description: "Retail customers")
        }
    }
}
