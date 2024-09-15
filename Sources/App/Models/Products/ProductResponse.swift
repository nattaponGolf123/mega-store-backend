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
    let category: ProductCategoryResponse?
    let images: [String]
    let coverImage: String?
    let tags: [String]
    let barcode: String?
    let manufacturer: String?
    let variants: [ProductVariantResponse]
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
        if let category = product.$category.value,
            let value = category {
            self.category = .init(from: value)
        } else {
            self.category = nil
        }
        self.images = product.images
        self.coverImage = product.coverImage
        self.manufacturer = product.manufacturer
        self.barcode = product.barcode
        self.tags = product.tags
        self.variants = product.variants.map { ProductVariantResponse(productCode: _code, from: $0) }
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
        case category
        case images
        case coverImage = "cover_image"
        case tags
        case variants
        case barcode
        case manufacturer
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
