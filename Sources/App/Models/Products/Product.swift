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

    @Field(key: "number")
    var number: Int

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var descriptionInfo: String?

    @Field(key: "unit")
    var unit: String

    @Field(key: "price")
    var price: Double

//    @Field(key: "category_id")
//    var categoryId: UUID?
    @OptionalParent(key: "category_id")
    var category: ProductCategory?

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

    @Field(key: "variants")
    var variants: [ProductVariant]

    init() { }

    init(id: UUID? = nil,
         number: Int = 1,
         name: String,
         description: String? = nil,
         unit: String = "",
         price: Double = 0,
         categoryId: ProductCategory.IDValue? = nil,
         manufacturer: String? = nil,
         barcode: String? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         variants: [ProductVariant] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.number = max(number, 1)
        self.name = name
        self.descriptionInfo = description
        self.unit = unit
        self.price = price
        self.$category.id = categoryId
        self.manufacturer = manufacturer
        self.barcode = barcode
        self.images = images
        self.coverImage = coverImage
        self.tags = tags
        self.variants = variants
        self.createdAt = createdAt ?? .init()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

}

extension Product { 
    struct Stub {
        static var steel: Product {
            .init(name: "Steel",
                  description: "Steel is an alloy of iron and carbon containing less than 2% carbon and 1% manganese and small amounts of silicon, phosphorus, sulphur and oxygen.",
                  unit: "kg",
                  price: 100.00,
                  categoryId: ProductCategory.Stub.steel.id,
                  manufacturer: "Steel Manufacturer",
                  barcode: "1234567890",
                  images: ["https://example.com/steel.jpg"],
                  coverImage: "https://example.com/steel.jpg",
                  tags: ["steel", "iron", "carbon"],
                  variants: [
                      .init(number: 1,
                            name: "Steel",
                            sku: "STL-001",
                            price: 100.00,
                            description: "Steel is an alloy of iron and carbon containing less than 2% carbon and 1% manganese and small amounts of silicon, phosphorus, sulphur and oxygen.",
                            image: "https://example.com/steel.jpg",
                            color: "Silver",
                            barcode: "1234567890",
                            dimensions: .init(length: 1,
                                              width: 1,
                                              height: 1,
                                              weight: 1,
                                              lengthUnit: "cm",
                                              widthUnit: "cm",
                                              heightUnit: "cm",
                                              weightUnit: "kg"))
                  ])
        }
    }
}

extension Product {
  
  static var units: [String] {    
    return ["peice", "kg", "litre", "gram", "meter", "centimeter", "inch", "foot", "yard"]
  }

}
