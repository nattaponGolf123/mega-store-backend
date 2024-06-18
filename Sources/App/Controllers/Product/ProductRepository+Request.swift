//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

extension ProductRepository {

    enum SortBy: String, Codable {
        case name
        case number
        case price
        case categoryId = "category_id"
        case createdAt = "created_at"
    }

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        
        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortOrder = .asc) {
            self.showDeleted = showDeleted
            self.page = page
            self.perPage = perPage
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }
        
        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }
    
    struct Search: Content {
        let q: String
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        
        init(q: String,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortOrder = .asc) {
            self.q = q
            self.page = page
            self.perPage = perPage
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.q = try container.decode(String.self, forKey: .q)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(q, forKey: .q)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }
        
        enum CodingKeys: String, CodingKey {
            case q
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }
    
    struct Create: Content, Validatable {
        let name: String
        let description: String?
        let price: Double
        let unit: String
        let categoryId: UUID?
        let images: [String]
        let coverImage: String?
        let tags: [String]
        
        init(name: String,
             description: String? = nil,
             price: Double,
             unit: String,
             categoryId: UUID? = nil,
             images: [String] = [],
             coverImage: String? = nil,
             tags: [String] = []) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
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
            case tags
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200))
            validations.add("price", as: Double.self, is: .range(0...))
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
        let tags: [String]?
        
        init(name: String? = nil,
             description: String? = nil,
             price: Double? = nil,
             unit: String? = nil,
             categoryId: UUID? = nil,
             images: [String]? = nil,
             coverImage: String? = nil,
             tags: [String]? = nil) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(String.self, forKey: .name)
            self.description = try? container.decode(String.self, forKey: .description)
            self.price = try? container.decode(Double.self, forKey: .price)
            self.unit = try? container.decode(String.self, forKey: .unit)
            self.categoryId = try? container.decode(UUID.self, forKey: .categoryId)
            self.images = try? container.decode([String].self, forKey: .images)
            self.coverImage = try? container.decode(String.self, forKey: .coverImage)
            self.tags = try? container.decode([String].self, forKey: .tags)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case price
            case unit
            case categoryId = "category_id"
            case images
            case coverImage = "cover_image"
            case tags
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200))
            validations.add("price", as: Double.self, is: .range(0...))
        }
    }
    
//    struct AddContact: Content {
//        let contactId: UUID
//        
//        enum CodingKeys: String, CodingKey {
//            case contactId = "contact_id"
//        }
//    }
//    
//    struct UpdateContact: Content {
//        let contactId: UUID
//        
//        enum CodingKeys: String, CodingKey {
//            case contactId = "contact_id"
//        }
//    }

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
            validations.add("name", as: String.self, is: .count(1...200))
            validations.add("price", as: Double.self, is: .range(0...))
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
            validations.add("name", as: String.self, is: .count(1...200))
            validations.add("price", as: Double.self, is: .range(0...))
        }
    }

}


/*
ProductVariant json
{
    "id": "UUID",
    "code": "PV00001",
    "name": "",
    "sku": "",
    "price": 123.44,
    "description": "",
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
*/
