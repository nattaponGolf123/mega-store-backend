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
    
    @Timestamp(key: "created_at", 
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", 
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil, 
         name: String,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.name = name
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension ProductCategory {
    struct Stub {
        
        static var group: [ProductCategory] {
            [
                .init(name: "Steel"),
                .init(name: "Cement"),
                .init(name: "Wood"),
                .init(name: "Paint"),
                .init(name: "Plumbing"),
            ]
        }
        
        static var steel: ProductCategory {
            .init(name: "Steel")
        }
    }
}

extension ProductCategory {

    struct Create: Content, Validatable {
        let name: String
        
        init(name: String) {
            self.name = name
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
        }
                
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...400))
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        
        init(name: String? = nil) {
            self.name = name
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(1...))
        }
    }

}