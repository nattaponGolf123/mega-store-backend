//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ServiceSchema {
    static var schema: String { Service.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("description", .string)
            .field("price", .double)
            .field("unit", .string)
            .field("category_id", .uuid)
            .field("images", .array(of: .string))
            .field("cover_image", .string)
            .field("tags", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
}

/*

final class Service: Model, Content {
    static let schema = "Services"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "unit")
    var unit: String

    @Field(key: "category_id")
    var categoryId: UUID?
    
    @Field(key: "images")
    var images: [String]
    
    @Field(key: "cover_image")
    var coverImage: String?

    @Field(key: "tags")
    var tags: [String]

    @Timestamp(key: "created_at",
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?
    
    init() { }

    init(id: UUID? = nil,
         name: String,
         description: String,
         price: Double,
         unit: String,
         categoryId: UUID? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.name = name
        self.description = description
        self.price = price
        self.unit = unit
        self.categoryId = categoryId
        self.images = images
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
}
*/
