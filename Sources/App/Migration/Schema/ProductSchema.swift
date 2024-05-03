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
            .field("description", .string, .required)
            .field("unit", .string, .required)
            .field("selling_price", .double, .required)
            .field("category_id", .uuid)
            .field("manufacturer", .string)
            .field("barcode", .string)
            .unique(on: "barcode")
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

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "unit")
    var unit: String 

    @Field(key: "selling_price")
    var sellingPrice: Double

    @Field(key: "category_id")
    var categoryId: UUID?

    @Field(key: "manufacturer")
    var manufacturer: String

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
        name: String,
         description: String,
         unit: String,
         sellingPrice: Double = 0,
         categoryId: UUID? = nil,
         manufacturer: String = "",
         barcode: String? = nil,         
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         suppliers: [UUID] = [],
         variants: [ProductVariant] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.unit = unit
        self.sellingPrice = sellingPrice
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
final class ProductVariant:Model, Content {
    static let schema = "ProductVariant"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "variant_id")
    var variantId: String
    
    @Field(key: "variant_name")
    var name: String
    
    @Field(key: "variant_sku")
    var sku: String
    
    @Field(key: "price")
    var sellingPrice: Double
    
    @Field(key: "additional_description")
    var additionalDescription: String
    
    @Field(key: "image")
    var image: String?
    
    @Field(key: "color")
    var color: String?
    
    @Field(key: "barcode")
    var barcode: String?
    
    @Field(key: "dimensions")
    var dimensions: ProductDimension?
    
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
         variantId: String? = nil,
         name: String,
         sku: String,
         sellingPrice: Double,
         additionalDescription: String,
         image: String? = nil,
         color: String? = nil,
         barcode: String? = nil,
         dimensions: ProductDimension? = nil,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        
        @UniqueVariantId
        var _variantId: String
        
        self.id = id ?? .init()
        self.variantId = variantId ?? _variantId
        self.name = name
        self.sku = sku
        self.sellingPrice = sellingPrice
        self.additionalDescription = additionalDescription
        self.image = image
        self.color = color
        self.barcode = barcode
        self.dimensions = dimensions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case variantId = "variant_id"
        case name = "variant_name"
        case sku = "variant_sku"
        case sellingPrice = "price"
        case additionalDescription = "additional_description"
        case image
        case color
        case barcode
        case dimensions
    }
}
*/