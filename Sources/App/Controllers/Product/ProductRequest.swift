//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/9/2567 BE.
//

import Foundation
import Vapor

struct ProductRequest {
    
    struct Create: Content, Validatable {
        let name: String
        let description: String?
        let price: Double
        let unit: String
        let categoryId: UUID?
        let images: [String]
        let coverImage: String?
        let manufacturer: String?
        let barcode: String?
        let tags: [String]
        
        init(name: String,
             description: String? = nil,
             price: Double,
             unit: String,
             categoryId: UUID? = nil,
             images: [String] = [],
             coverImage: String? = nil,
             manufacturer: String? = nil,
             barcode: String? = nil,
             tags: [String] = []) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.manufacturer = manufacturer
            self.barcode = barcode
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                     forKey: .description)
            self.price = try container.decode(Double.self,
                                              forKey: .price)
            self.unit = try container.decode(String.self,
                                             forKey: .unit)
            self.categoryId = try? container.decode(UUID.self,
                                                    forKey: .categoryId)
            self.images = try container.decode([String].self,
                                               forKey: .images)
            self.coverImage = try? container.decode(String.self,
                                                    forKey: .coverImage)
            self.manufacturer = try? container.decode(String.self,
                                                     forKey: .manufacturer)
            self.barcode = try? container.decode(String.self,
                                                    forKey: .barcode)
            self.tags = try container.decode([String].self,
                                             forKey: .tags)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case price
            case unit
            case categoryId = "category_id"
            case images
            case coverImage = "cover_image"
            case manufacturer
            case barcode
            case tags
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200), required: true)
            validations.add("price", as: Double.self, is: .range(0...), required: true)
        }
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        let price: Double?
        let unit: String?
        let categoryId: UUID?
        let images: [String]?
        let coverImage: String?
        let manufacturer: String?
        let barcode: String?
        let tags: [String]?
        
        init(name: String? = nil,
             description: String? = nil,
             price: Double? = nil,
             unit: String? = nil,
             categoryId: UUID? = nil,
             images: [String]? = nil,
             coverImage: String? = nil,
             manufacturer: String? = nil,
             barcode: String? = nil,
             tags: [String]? = nil) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.manufacturer = manufacturer
            self.barcode = barcode
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(String.self, 
                                              forKey: .name)
            self.description = try? container.decode(String.self, 
                                                     forKey: .description)
            self.price = try? container.decode(Double.self, 
                                               forKey: .price)
            self.unit = try? container.decode(String.self, 
                                              forKey: .unit)
            self.categoryId = try? container.decode(UUID.self, 
                                                    forKey: .categoryId)
            self.images = try? container.decode([String].self, 
                                                forKey: .images)
            self.coverImage = try? container.decode(String.self,
                                                    forKey: .coverImage)
            self.manufacturer = try? container.decode(String.self, 
                                                      forKey: .manufacturer)
            self.barcode = try? container.decode(String.self,
                                                 forKey: .barcode)
            self.tags = try? container.decode([String].self, 
                                              forKey: .tags)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case price
            case unit
            case categoryId = "category_id"
            case images
            case coverImage = "cover_image"
            case manufacturer
            case barcode
            case tags
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200), required: false)
            validations.add("price", as: Double.self, is: .range(0...), required: false)
        }
    }
    
   struct AddContact: Content {
       let contactId: UUID
       
       enum CodingKeys: String, CodingKey {
           case contactId = "contact_id"
       }
       
   }

    struct CreateVariant: Content, Validatable {
        
        let name: String
        let sku: String?
        let price: Double
        let description: String?
        let image: String?
        let color: String?
        let barcode: String?
        let dimensions: ProductDimension?
        
        init(name: String,
             sku: String? = nil,
             price: Double = 0,
             description: String? = nil,
             image: String? = nil,
             color: String? = nil,
             barcode: String? = nil,
             dimensions: ProductDimension? = nil) {
            self.name = name
            self.sku = sku
            self.price = price
            self.description = description
            self.image = image
            self.color = color
            self.barcode = barcode
            self.dimensions = dimensions
             }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.sku = try? container.decode(String.self, forKey: .sku)
            self.price = try container.decode(Double.self, forKey: .price)
            self.description = try? container.decode(String.self, forKey: .description)
            self.image = try? container.decode(String.self, forKey: .image)
            self.color = try? container.decode(String.self, forKey: .color)
            self.barcode = try? container.decode(String.self, forKey: .barcode)
            self.dimensions = try? container.decode(ProductDimension.self, forKey: .dimensions)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case sku
            case price
            case description
            case image
            case color
            case barcode
            case dimensions
        }

        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200), required: true)
            validations.add("price", as: Double.self, is: .range(0...), required: true)
            validations.add("barcode", as: String.self, is: .count(13...13), required: false)
            validations.add("barcode", as: String.self, is: .characterSet(.decimalDigits), required: false)
        }

    }

    struct UpdateVariant: Content, Validatable {
        let name: String?
        let sku: String?
        let price: Double?
        let description: String?
        let image: String?
        let color: String?
        let barcode: String?
        let dimensions: ProductDimension?

        init(name: String? = nil,
             sku: String? = nil,
             price: Double? = nil,
             description: String? = nil,
             image: String? = nil,
             color: String? = nil,
             barcode: String? = nil,
             dimensions: ProductDimension? = nil) {
            self.name = name
            self.sku = sku
            self.price = price
            self.description = description
            self.image = image
            self.color = color
            self.barcode = barcode
            self.dimensions = dimensions
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(String.self, forKey: .name)
            self.sku = try? container.decode(String.self, forKey: .sku)
            self.price = try? container.decode(Double.self, forKey: .price)
            self.description = try? container.decode(String.self, forKey: .description)
            self.image = try? container.decode(String.self, forKey: .image)
            self.color = try? container.decode(String.self, forKey: .color)
            self.barcode = try? container.decode(String.self, forKey: .barcode)
            self.dimensions = try? container.decode(ProductDimension.self, forKey: .dimensions)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case sku
            case price
            case description
            case image
            case color
            case barcode
            case dimensions
        }

        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200), required: false)
            validations.add("price", as: Double.self, is: .range(0...), required: false)
            validations.add("barcode", as: String.self, is: .count(13...13), required: false)
            validations.add("barcode", as: String.self, is: .characterSet(.decimalDigits), required: false)
        }
    }
}
