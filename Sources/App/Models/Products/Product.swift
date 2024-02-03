//
//  File.swift
//
//
//  Created by IntrodexMac on 28/1/2567 BE.
//

import Foundation
import Fluent
import Vapor

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

    @Field(key: "price")
    var price: Double

    @Field(key: "category_id")
    var categoryID: UUID

    @OptionalField(key: "manufacturer")
    var manufacturer: String?

    @OptionalField(key: "barcode")
    var barcode: String?

    @OptionalField(key: "image_url")
    var imageUrl: String?

    @Field(key: "tags")
    var tags: [String]

    @Field(key: "variants")
    var variants: [ProductVariant]
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete, format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil,
         name: String,
         description: String,
         unit: String,
         price: Double,
         categoryID: UUID,
         manufacturer: String? = nil,
         barcode: String? = nil,
         imageUrl: String? = nil,
         tags: [String] = [],
         variants: [ProductVariant] = [],
         createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.unit = unit
        self.price = price
        self.categoryID = categoryID
        self.manufacturer = manufacturer
        self.barcode = barcode
        self.imageUrl = imageUrl
        self.tags = tags
        self.variants = variants
        self.createdAt = createdAt ?? Date()
    }

}

/*
 {
     "id": "UUID",
     "name": "",
     "description": "",
     "unit": "unit",
     "price": 100.11,
     "category_id": 1,
     "manufacturer": "",
     "barcode": "UniqueVariantBarcode",  // Added barcode field
     "date_added": "ISODate",
     "last_updated": "ISODate",
     "delete_at": "ISODate",
     "image": "",
     "tags": ["abc", "def"],
     "variants": [
         {
             "id": "UUID",
             "variant_id": "id",
             "variant_name": "",
             "variant_sku": "",
             "price": 123.44,
             "additional_description": "",
             "image": "",
             "color": "Red",
             "barcode": "UniqueVariantBarcode",  // Added barcode field
             "dimensions": {
                 "length": 1,
                 "width": 1,
                 "height": 1,
                 "weight": 1,
                 "length_unit": "cm",
                 "weight_unit": "kg"
             }
         }
     ]
 }
 */
