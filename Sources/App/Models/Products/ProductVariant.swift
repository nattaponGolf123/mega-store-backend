//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ProductVariant:Model, Content {
    static let schema = "ProductVariant"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "number")
    var number: Int

    @Field(key: "name")
    var name: String
    
    @Field(key: "sku")
    var sku: String?
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "description")
    var description: String?
    
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
         number: Int = 1,
         name: String,
         sku: String? = nil,
         price: Double = 0,
         description: String? = nil,
         image: String? = nil,
         color: String? = nil,
         barcode: String? = nil,
         dimensions: ProductDimension? = nil,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {        
        
        self.id = id ?? .init()
        self.number = number
        self.name = name
        self.description = description
        self.sku = sku
        self.price = price        
        self.image = image
        self.color = color
        self.barcode = barcode
        self.dimensions = dimensions
        self.createdAt = createdAt ?? .init()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

}

 extension ProductVariant { 
     struct Stub {

        static var metal: ProductVariant {
            return .init(name: "Metal Variant",
                         sku: "MTL-123",
                         price: 100.11,
                         description: "Metal Variant Description",
                         color: "Silver",
                         barcode: "MTL-123-456",
                         dimensions: .init(length: 1,
                                           width: 1,
                                           height: 1,
                                           weight: 1,
                                           lengthUnit: "cm",
                                           weightUnit: "kg"))
        }

     }
 }

/*
 {
 "id": "UUID",
 "description": "",
 "unit_id": 1,
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
