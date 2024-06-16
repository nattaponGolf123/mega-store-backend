//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Vapor
import Fluent

class ServiceCategorySchema {    
    static var schema: String { ServiceCategory.schema }
    
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
