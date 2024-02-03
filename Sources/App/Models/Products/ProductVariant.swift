//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

struct ProductVariant: Codable, Content {
    var id: UUID?
    var variantID: UUID
    var variantName: String
    var variantSKU: String
    var price: Double
    var additionalDescription: String?
    var image: String?
    var color: String?
    var barcode: String?
    var dimensions: ProductDimensions?

    init(id: UUID? = nil,
         variantID: UUID,
         variantName: String,
         variantSKU: String,
         price: Double,
         additionalDescription: String? = nil,
         image: String? = nil,
         color: String? = nil,
         barcode: String? = nil,
         dimensions: ProductDimensions? = nil) {
        self.id = id ?? UUID()
        self.variantID = variantID
        self.variantName = variantName
        self.variantSKU = variantSKU
        self.price = price
        self.additionalDescription = additionalDescription
        self.image = image
        self.color = color
        self.barcode = barcode
        self.dimensions = dimensions
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(variantID, forKey: .variantID)
        try container.encode(variantName, forKey: .variantName)
        try container.encode(variantSKU, forKey: .variantSKU)
        try container.encode(price, forKey: .price)
        try container.encode(additionalDescription, forKey: .additionalDescription)
        try container.encode(image, forKey: .image)
        try container.encode(color, forKey: .color)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(dimensions, forKey: .dimensions)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        variantID = try container.decode(UUID.self, forKey: .variantID)
        variantName = try container.decode(String.self, forKey: .variantName)
        variantSKU = try container.decode(String.self, forKey: .variantSKU)
        price = try container.decode(Double.self, forKey: .price)
        additionalDescription = try? container.decode(String.self, forKey: .additionalDescription)
        image = try? container.decode(String.self, forKey: .image)
        color = try? container.decode(String.self, forKey: .color)
        barcode = try? container.decode(String.self, forKey: .barcode)
        dimensions = try? container.decode(ProductDimensions.self, forKey: .dimensions)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case variantID = "variant_id"
        case variantName = "variant_name"
        case variantSKU = "variant_sku"
        case price
        case additionalDescription = "additional_description"
        case image = "image_url"
        case color
        case barcode
        case dimensions
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
