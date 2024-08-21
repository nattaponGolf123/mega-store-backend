//
//  File.swift
//  
//
//  Created by IntrodexMac on 22/8/2567 BE.
//

import Foundation
import Vapor

struct ServiceRequest {
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
            validations.add("name", as: String.self, is: .count(1...200), required: false)
            validations.add("price", as: Double.self, is: .range(0...), required: false)
        }
    }
    
    //    enum SortBy: String, Codable {
    //        case name
    //        case number
    //        case price
    //        case categoryId = "category_id"
    //        case createdAt = "created_at"
    //    }
    //
}
