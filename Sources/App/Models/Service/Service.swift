//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class Service: Model, Content {
    static let schema = "Services"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "number")
    var number: Int
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "unit")
    var unit: String
    
//    @Field(key: "category_id")
//    var categoryId: UUID?
    @OptionalParent(key: "category_id")
    var category: ServiceCategory?
    
    @Field(key: "images")
    var images: [String]
    
    @Field(key: "cover_image")
    var coverImage: String?
    
    @Field(key: "tags")
    var tags: [String]
    
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
         number: Int = 1,
         name: String,
         description: String? = nil,
         price: Double = 0,
         unit: String = "",
         categoryId: ServiceCategory.IDValue? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.number = number
        self.name = name
        self.description = description
        self.price = price
        self.unit = unit
        self.$category.id = categoryId
        self.images = images
        self.coverImage = coverImage
        self.tags = tags
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    init(id: UUID? = nil,
         number: Int,
         name: String,
         description: String?,
         price: Double = 0,
         unit: String = "",
         category: ServiceCategory,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.number = number
        self.name = name
        self.description = description
        self.price = price
        self.unit = unit
        self.category = category
        self.images = images
        self.coverImage = coverImage
        self.tags = tags
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
//
//    init(id: UUID? = nil,
//         number: Int,
//         name: String,
//         description: String? = nil,
//         price: Double = 0,
//         unit: String = "",
//         category: ServiceCategory? = nil,
//         images: [String] = [],
//         coverImage: String? = nil,
//         tags: [String] = [],
//         createdAt: Date? = nil,
//         updatedAt: Date? = nil,
//         deletedAt: Date? = nil) {
//        self.id = id ?? .init()
//        self.number = number
//        self.name = name
//        self.description = description
//        self.price = price
//        self.unit = unit
//        self.category = category
//        self.images = images
//        self.coverImage = coverImage
//        self.tags = tags
//        self.createdAt = createdAt ?? Date()
//        self.updatedAt = updatedAt
//        self.deletedAt = deletedAt
//    }
//    
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
 */

extension Service {
    struct Stub {
        
        static var group: [Service] {
            [
                self.yoga,
                self.pilates,
                self.spinning
            ]
        }
        
        static var yoga: Service {
            .init(number: 1,
                  name: "Yoga Class",
                  description: "A one-hour yoga class focusing on relaxation and flexibility.",
                  price: 20.00,
                  unit: "hour",
                  //categoryId: nil,
                  images: [
                    "https://example.com/yoga-class-image1.jpg",
                    "https://example.com/yoga-class-image2.jpg"
                  ],
                  coverImage: nil,
                  tags: [])
        }
        
        static var pilates: Service {
            .init(number: 2,
                  name: "Pilates Class",
                  description: "A one-hour pilates class focusing on core strength and flexibility.",
                  price: 25.00,
                  unit: "hour",
                  //categoryId: nil,
                  images: [
                    "https://example.com/pilates-class-image1.jpg",
                    "https://example.com/pilates-class-image2.jpg"
                  ])
        }
        
        static var spinning: Service {
            .init(number: 3,
                  name: "Spinning Class",
                  description: "A one-hour spinning class focusing on cardio and endurance.",
                  price: 15.00,
                  unit: "hour",
                  //categoryId: .init(),
                  images: [
                    "https://example.com/spinning-class-image1.jpg",
                    "https://example.com/spinning-class-image2.jpg"
                  ])
        }
    }
}
