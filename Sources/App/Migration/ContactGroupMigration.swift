//
//  ContactGroupMigration.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct ContactGroupMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await ContactGroupSchema.createBuilder(database: database).create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(ContactGroupSchema.schema).delete()
    }
}
