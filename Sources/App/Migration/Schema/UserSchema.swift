//
//  File.swift
//
//
//  Created by IntrodexMac on 3/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class UserSchema {
    static var schema: String { User.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password_hash", .string, .required)
            .field("fullname", .string, .required)
            .unique(on: "fullname")
            .field("type", .string, .required)
            .field("token", .string)
            .unique(on: "token")
            .field("expried", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}

/*
 {
 "username": "theresa59",
 "password": "^7Wqb49P*!",
 "token": "JWT fe61b720b50e8c1755af8250bfb692f20d3b2ed3e1c3d6a42e4ade5e0d46b0b5",
 "date_added": "1995-03-13T16:21:25",
 "last_updated": "1983-02-27T12:25:49",
 "delete_at": "1982-10-11T12:02:34"
 }
 */
