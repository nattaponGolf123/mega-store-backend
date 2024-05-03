//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct ProductMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await ProductSchema.createBuilder(database: database).create()
        
        // new mocks
        try await Product.Stub.steel.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(ProductSchema.schema).delete()
    }
}

