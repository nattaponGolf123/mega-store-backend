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
        try await SupplierGroup.Stub.supplierGroup1.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(SupplierGroupSchema.schema).delete()
    }
}
