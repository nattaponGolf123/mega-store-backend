//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation
import Vapor

struct ServiceResponse: Content {
    let id: UUID?
    let code: String
    let name: String
    let description: String?
    let price: Double
    let unit: String
    let category: ServiceCategoryResponse?
    let images: [String]
    let coverImage: String?
    let tags: [String]
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from service: Service) {
        self.id = service.id
        self.code = ServiceCode(number: service.number).code
        self.name = service.name
        self.description = service.description
        self.price = service.price
        self.unit = service.unit
        if let category = service.$category.value,
            let value = category {
            self.category = .init(from: value)
        } else {
            self.category = nil
        }
        self.images = service.images
        self.coverImage = service.coverImage
        self.tags = service.tags
        self.createdAt = service.createdAt
        self.updatedAt = service.updatedAt
        self.deletedAt = service.deletedAt
    }   
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case description
        case price
        case unit
        case category = "category"
        case images
        case coverImage = "cover_image"
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
}
