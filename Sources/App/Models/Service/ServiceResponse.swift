//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation
import Vapor
import Fluent

struct ServiceResponse: Content {
    let id: UUID?
    let code: String
    let name: String
    let description: String?
    let price: Double
    let unit: String
    let categoryId: UUID?
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
        self.categoryId = service.categoryId
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
        case categoryId = "category_id"
        case images
        case coverImage = "cover_image"
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
}
