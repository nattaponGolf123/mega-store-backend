//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation
import Vapor

struct ProductResponse: Content {
    let id: UUID?
    let code: String
    let name: String
    let description: String?
    let price: Double
    let unit: String?
    let categoryId: UUID?
    let images: [String]
    let coverImage: String?
    let tags: [String]
    let variants: [ProductVariantResponse]
    let contacts: [UUID]
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from product: Product) {
        self.id = product.id
        let _code = ProductCode(number: product.number).code
        self.code = _code
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.unit = product.unit
        self.categoryId = product.categoryId
        self.images = product.images
        self.coverImage = product.coverImage
        self.tags = product.tags
        self.variants = product.variants.map { ProductVariantResponse(productCode: _code, from: $0) }
        self.contacts = product.contacts
        self.createdAt = product.createdAt
        self.updatedAt = product.updatedAt
        self.deletedAt = product.deletedAt
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
        case variants
        case contacts
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
