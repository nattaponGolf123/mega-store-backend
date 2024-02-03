//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("fullname", .string, .required)
            .field("is_admin", .bool, .required, .custom("DEFAULT FALSE"))
            .field("token", .string)
            .field("tokenExpried", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("devared_at", .datetime)
            .unique(on: "username")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
