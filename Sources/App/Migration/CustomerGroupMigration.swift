//
//  CustomerGroupMigration.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct CustomerGroupMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await CustomerGroupSchema.createBuilder(database: database).create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(CustomerGroupSchema.schema).delete()
    }
}
