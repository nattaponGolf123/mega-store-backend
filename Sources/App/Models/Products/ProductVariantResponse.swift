//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/6/2567 BE.
//

import Foundation
import Vapor

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
    
    init(productCode: String,
         from variant: ProductVariant) {
        self.id = variant.id
        self.code = ProductVariantCode(productCode: productCode, number: variant.number).code
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
