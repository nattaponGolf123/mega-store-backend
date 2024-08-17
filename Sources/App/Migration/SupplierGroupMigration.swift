//
//  SupplierGroupMigration.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct SupplierGroupMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await SupplierGroupSchema.createBuilder(database: database).create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(SupplierGroupSchema.schema).delete()
    }
}
