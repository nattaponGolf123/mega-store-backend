//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct CreateUserMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        //try await database.schema(User.schema).delete()
        
        try await UserSchema.createBuilder(database: database).create()
        
        // new mock admin user
        try await User.Stub.admin.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
