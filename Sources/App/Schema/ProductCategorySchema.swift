//
//  File.swift
//  
//
//  Created by IntrodexMac on 29/1/2567 BE.
//

import Foundation
import Vapor
import Fluent

class ProductCategorySchema {
    static var schema: String { ProductCategory.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "name")
    }
}
