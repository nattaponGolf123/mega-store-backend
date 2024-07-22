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
         description: String? = nil,
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
    struct Stub {

        static var localCustomer: ContactGroup {
            .init(name: "Local Customer",
                  description: "Local Customer Description")
        }

        static var internationalCustomer: ContactGroup {
            .init(name: "International Customer",
                  description: "International Customer Description")
        }
        
        static var groups: [ContactGroup] {
            [
                .init(name: "Contact Group 1",
                      description: "Contact Group 1 Description"),
                .init(name: "Contact Group 2",
                     description: "Contact Group 2 Description"),
                .init(name: "Contact Group 3",
                        description: "Contact Group 3 Description"),
            ]
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
