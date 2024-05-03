//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct SupplierMigration: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await SupplierSchema.createBuilder(database: database).create()
        
        // new mocks
        //try await Supplier.Stub.transport.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(SupplierSchema.schema).delete()
    }
}