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

extension Product { 
    struct Stub {
        static var steel: Product {
            return Product(name: "Steel",
             description: "Steel Description",
              unit: "Kg",
               sellingPrice: 100.11,
                categoryId: nil,
                 manufacturer: "Steel Manufacturer",
                variants: [ProductVariant.Stub.steelVariant])
        }
    }
}

extension Product {
  
  static var units: [String] {
    return ["Peice", "Kg", "Litre", "Gram", "Meter", "Centimeter", "Inch", "Foot", "Yard"]
  }

}

/*
 {
	"id": "UUID",
    "name" :  "Product Name",
	"description": "",
	"unit": "Peice",
	"selling_price": 100.11, // selling price include vat
	"category_id": "asdqwe", // ref to product_category: UUID or null
	"manufacturer": "",
	"barcode": "UniqueVariantBarcode",  // Added barcode field
	"created_at": "ISODate",
	"updated_at": "ISODate",
	"deleted_at": "ISODate",
	"images": [""], // image url 
    "cover_image": "", // image url
	"tags": ["abc", "def"],
    "suppliers: [], // ref to supplier uuid
	"variants": [
		{
			"id": "UUID", // unique UUID , store as sub-document in mongo
			"variant_id": "id",
			"variant_name": "",
			"variant_sku": "",
			"price": 123.44,
			"additional_description": "",
			"image": "",
			"color": "Red",
			"barcode": "123232213", 
			"dimensions": {
				"length": 1,
				"width": 1,
				"height": 1,
				"weight": 1,
				"length_unit": "cm",
                "width_unit": "cm",
                "height_unit": "cm",                
				"weight_unit": "kg"
			}
		}
	]
}
 */
