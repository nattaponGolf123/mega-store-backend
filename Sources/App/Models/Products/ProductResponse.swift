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
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from product: Product) {
        self.id = product.id
        self.code = ProductCode(number: product.number).code
        self.name = product.name
        self.description = product.description
        self.price = product.price
        self.unit = product.unit
        self.categoryId = product.categoryId
        self.images = product.images
        self.coverImage = product.coverImage
        self.tags = product.tags
        self.variants = product.variants.map { ProductVariantResponse(from: $0) }
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
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ProductVariantResponse: Content {
    let id: UUID?
    let code: String
    let name: String
    let sku: String?
    let price: Double
    let description: String?
    let image: String?
    let color: String?
    let barcode: String?
    let dimensions: ProductDimension?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from variant: ProductVariant) {
        self.id = variant.id
        self.code = ProductVariantCode(number: variant.number).code
        self.name = variant.name
        self.sku = variant.sku
        self.price = variant.price
        self.description = variant.description
        self.image = variant.image
        self.color = variant.color
        self.barcode = variant.barcode
        self.dimensions = variant.dimensions
        self.createdAt = variant.createdAt
        self.updatedAt = variant.updatedAt
        self.deletedAt = variant.deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case sku
        case price
        case description
        case image
        case color
        case barcode
        case dimensions
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
