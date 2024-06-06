//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ContactGroup: Model, Content {
    static let schema = "ContactGroups"
    
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
         description: String?,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? UUID()
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
}

extension ContactGroup {
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

extension ContactGroup {
    struct Stub {
        
        static var group: [ContactGroup] {
            [
                .init(name: "Contact Group 1",
                      description: "Contact Group 1 Description"),
                .init(name: "Contact Group 2",
                      description: "Contact Group 2 Description"),
                .init(name: "Contact Group 3",
                      description: "Contact Group 3 Description"),
                .init(name: "Contact Group 4",
                      description: "Contact Group 4 Description"),
                .init(name: "Contact Group 5",
                      description: "Contact Group 5 Description"),
            ]
        }
        
        static var ContactGroup1: ContactGroup {
            .init(name: "Contact Group 1",
                  description: "Contact Group 1 Description")
        }
    }

}

/*
{
    "id": "00000000-0000-0000-0000-000000000000",
    "name": "Contact Group 1",
    "description": "Contact Group 1 Description",
    "created_at": "2021-05-03T00:00
    "updated_at": "2021-05-03T00:00
    "deleted_at": "2021-05-03T00:00
}
*/
