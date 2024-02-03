//
//  File.swift
//  
//
//  Created by IntrodexMac on 29/1/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ProductCategory: Model, Content {
    static let schema = "ProductCategories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String    
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete, format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil, 
         name: String,
         createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt ?? Date()
    }
}
