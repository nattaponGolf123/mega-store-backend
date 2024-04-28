//
//  File.swift
//  
//
//  Created by IntrodexMac on 29/1/2567 BE.
//

import Foundation
import Vapor
import Fluent

class ProductSchema {
    static var schema: String { Product.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .field("price", .double, .required)
            .field("description", .string)
            .field("unit", .string, .required)
            .field("category_id", .uuid, .references(ProductCategory.schema, "id"))
            .unique(on: "name")
    }
    
}
