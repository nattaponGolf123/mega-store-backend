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
            .unique(on: "name")
            .field("number", .int, .required)
            .unique(on: "number")
            .field("description", .string)
            .field("price", .double)
            .field("unit", .string)
            .field("category_id", .uuid)
            .field("manufacturer", .string)
            .field("barcode", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .field("images", .array(of: .string))
            .field("cover_image", .string)
            .field("tags", .array(of: .string))
            .field("suppliers", .array(of: .uuid))
            .field("variants", .array(of: .json))
    }
    
}

/*
final class Product: Model, Content {
    static let schema = "Products"
   
    @ID(key: .id)
    var id: UUID?

    @Field(key: "number")
    var number: Int

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String?

    @Field(key: "unit")
    var unit: String?

    @Field(key: "price")
    var price: Double

    @Field(key: "category_id")
    var categoryId: UUID?

    @Field(key: "manufacturer")
    var manufacturer: String?

    @Field(key: "barcode")
    var barcode: String?

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

    @Field(key: "images")
    var images: [String]

    @Field(key: "cover_image")
    var coverImage: String?

    @Field(key: "tags")
    var tags: [String]

    @Field(key: "suppliers")
    var suppliers: [UUID]

    @Field(key: "variants")
    var variants: [ProductVariant]

    init() { }

    init(id: UUID? = nil,
         number: Int = 1,
         name: String,
         description: String? = nil,
         unit: String? = nil,
         price: Double,
         categoryId: UUID? = nil,
         manufacturer: String? = nil,
         barcode: String? = nil,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         suppliers: [UUID] = [],
         variants: [ProductVariant] = []) {
        self.id = id ?? .init()
        self.number = number
        self.name = name
        self.description = description
        self.unit = unit
        self.price = price
        self.categoryId = categoryId
        self.manufacturer = manufacturer
        self.barcode = barcode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.images = images
        self.coverImage = coverImage
        self.tags = tags
        self.suppliers = suppliers
        self.variants = variants
    }

}
*/