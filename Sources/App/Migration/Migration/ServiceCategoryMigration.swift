//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Fluent
import Vapor

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
