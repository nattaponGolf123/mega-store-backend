//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct SupplierGroupMigration: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await SupplierGroupSchema.createBuilder(database: database).create()
        
        // new mocks
        //try await SupplierGroup.Stub.transport.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(SupplierGroupSchema.schema).delete()
    }
}

/*
 import Fluent
 import Vapor

final class SupplierGroup: Model, Content {
    static let schema = "SupplierGroups"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

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
         description: String,
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

 struct ServiceCategoryMigration: AsyncMigration {
     func prepare(on database: Database) async throws {
         try await ServiceCategorySchema.createBuilder(database: database).create()
         
         // new mocks
         try await ServiceCategory.Stub.transport.save(on: database)
     }

     func revert(on database: Database) async throws {
         try await database.schema(ServiceCategorySchema.schema).delete()
     }
 }

 */
