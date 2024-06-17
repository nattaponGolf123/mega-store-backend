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

extension ServiceRepository {

    enum SortBy: String, Codable {
        case name
        case number
        case price
        case createdAt = "created_at"
    }

    enum SortByOrder: String, Codable {
        case asc
        case desc
    }

    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortByOrder
        
        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortByOrder = .asc) {
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
            self.sortOrder = (try? container.decode(SortByOrder.self, forKey: .sortOrder)) ?? .asc
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
            case page = "page"
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
        let sortOrder: SortByOrder
        
        init(q: String,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortByOrder = .asc) {
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
            self.sortOrder = (try? container.decode(SortByOrder.self, forKey: .sortOrder)) ?? .asc
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
            case name = "name"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(3...200))
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
            case name = "name"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(3...200))
            validations.add("price", as: Double.self, is: .range(0...))
        }
    }
}
