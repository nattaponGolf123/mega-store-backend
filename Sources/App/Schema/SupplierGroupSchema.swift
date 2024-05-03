//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

class SupplierGroupSchema {
    static var schema: String { SupplierGroup.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("description", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}

/*
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

 */
