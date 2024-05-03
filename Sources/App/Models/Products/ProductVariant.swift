//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

@propertyWrapper
struct UniqueVariantId {
    private var value: String?
    
    var wrappedValue: String {
        mutating get {
            if let existingValue = value {
                return existingValue
            } else {
                let newValue = generateRandomString()
                value = newValue
                return newValue
            }
        }
    }
    
    private func generateRandomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map { _ in letters.randomElement()! })
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

extension ProductVariant { 
    struct Stub {
        static var steelVariant: ProductVariant {
            return .init(name: "Steel Variant",
                         sku: "STL-123",
                         sellingPrice: 100.11,
                         additionalDescription: "Steel Variant Description",
                         color: "Silver",
                         barcode: "STL-123-456",
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
