//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/8/2567 BE.
//

import Foundation

import Vapor

struct ServiceCategoryResponse: Content {
    let id: UUID?
    let name: String
    let description: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from: ServiceCategory) {
        self.id = from.id
        self.name = from.name
        self.description = from.description
        self.createdAt = from.createdAt
        self.updatedAt = from.updatedAt
        self.deletedAt = from.deletedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
/*
 
 final class ServiceCategory: Model, Content {
     static let schema = "ServiceCategories"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "name")
     var name: String
     
     @Field(key: "description")
     var description: String?
     
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
          description: String? = nil,
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil) {
         self.id = id ?? UUID()
         self.name = name
         self.description = description
         self.createdAt = createdAt
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
     }
 }

 extension ServiceCategory {
     struct Stub {
         
         static var group: [ServiceCategory] {
             [
                 .init(name: "Transport"),
                 .init(name: "Food"),
                 .init(name: "Entertainment"),
             ]
         }
         
         static var transport: ServiceCategory {
             .init(name: "Transport",
                   description: "Transportation services")
         }
     }
 }

 */
