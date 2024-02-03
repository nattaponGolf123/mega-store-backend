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
    static let schema: String = "Users"
    
//    static func createBuilder(database: Database) -> SchemaBuilder {
//        database.schema(Self.schema)
//            .id()
//            .field("username", .string, .required)
//            .field("password_hash", .string, .required)
//            .field("description", .string)
//            .field("token", .string)
//            .field("date_added", .datetime, .required , .auto)
//            .field("last_updated", .datetime)
//            .unique(on: "username")
//            .unique(on: "token")
//            .unique(on: "password_hash")
//    }
    
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
