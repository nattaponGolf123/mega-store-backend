//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ServiceCategory: Model, Content {
    static let schema = "ServiceCategories"
    
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

extension ServiceCategory {
    struct Stub {
        
       static var group: [ServiceCategory] {
           [
               .init(name: "Transport"),
               .init(name: "Food"),
               .init(name: "Entertainment"),
           ]
       }
        
        static var transport: ServiceCategory {
            .init(name: "Transport",
                  description: "Transportation services")
        }
    }
}
