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
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "unit")
    var unit: String

    @Field(key: "category_id")
    var categoryId: UUID?
    
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
         name: String,
         description: String,
         price: Double,
         unit: String,
         categoryId: UUID? = nil,
         images: [String] = [],
         coverImage: String? = nil,
         tags: [String] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil) {
        self.id = id ?? .init()
        self.name = name
        self.description = description
        self.price = price
        self.unit = unit
        self.categoryId = categoryId
        self.images = images
        self.createdAt = createdAt ?? Date()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
//    func category(on database: Database) async throws -> ServiceCategory? {
//        guard 
//            let categoryId = self.categoryId
//        else { return nil }
//
//        return try await ServiceCategory.query(on: database)
//            .filter(\.$id == categoryId)
//            .first()
//    }
}

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
                .init(name: "Yoga Class",
                    description: "A one-hour yoga class focusing on relaxation and flexibility.",
                    price: 20.00,
                    unit: "hour",
                    categoryId: nil,
                    images: [
                        "https://example.com/yoga-class-image1.jpg",
                        "https://example.com/yoga-class-image2.jpg"
                    ])
            }
            
            static var pilates: Service {
                .init(name: "Pilates Class",
                    description: "A one-hour pilates class focusing on core strength and flexibility.",
                    price: 25.00,
                    unit: "hour",
                    categoryId: nil,
                    images: [
                        "https://example.com/pilates-class-image1.jpg",
                        "https://example.com/pilates-class-image2.jpg"
                    ])
            }
            
            static var spinning: Service {
                .init(name: "Spinning Class",
                    description: "A one-hour spinning class focusing on cardio and endurance.",
                    price: 15.00,
                    unit: "hour",
                    categoryId: .init(),
                    images: [
                        "https://example.com/spinning-class-image1.jpg",
                        "https://example.com/spinning-class-image2.jpg"
                    ])
            }
    }
}

extension Service {

    struct Create: Content, Validatable {
        let name: String
        let description: String
        let price: Double
        let unit: String
        let categoryId: UUID?
        let images: [String]
        let coverImage: String?
        let tags: [String]
        
        init(name: String,
             description: String,
             price: Double,
             unit: String,
             categoryId: UUID? = nil,
             images: [String] = [],
             coverImage: String? = nil,
             tags: [String] = []) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try container.decode(String.self,
                                                    forKey: .description)
            self.price = try container.decode(Double.self,
                                              forKey: .price)
            self.unit = try container.decode(String.self,
                                             forKey: .unit)
            self.categoryId = try? container.decode(UUID.self,
                                                    forKey: .categoryId)
            self.images = try container.decode([String].self,
                                               forKey: .images)
            self.coverImage = try? container.decode(String.self,
                                                    forKey: .coverImage)
            self.tags = try container.decode([String].self,
                                             forKey: .tags)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...400))
            validations.add("description", as: String.self,
                            is: .count(3...))
            validations.add("price", as: Double.self,
                            is: .range(0...))
            validations.add("unit", as: String.self,
                            is: .count(1...))
            validations.add("category_id", as: UUID?.self,
                            required: false)
            validations.add("images", as: [String].self,
                            is: !.empty)
            validations.add("cover_image", as: String?.self,
                            required: false)
            validations.add("tags", as: [String].self,
                            is: !.empty)
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        let price: Double?
        let unit: String?
        let categoryId: UUID?
        let images: [String]?
        let coverImage: String?
        let tags: [String]?
        
        init(name: String? = nil,
             description: String? = nil,
             price: Double? = nil,
             unit: String? = nil,
             categoryId: UUID? = nil,
             images: [String]? = nil,
             coverImage: String? = nil,
             tags: [String]? = nil) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
            case price = "price"
            case unit = "unit"
            case categoryId = "category_id"
            case images = "images"
            case coverImage = "cover_image"
            case tags = "tags"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(1...400),
                            required: true)
            // validations.add("description", as: String.self,
            //                 is: .count(...400),
            //                 required: false)
            validations.add("price", as: Double.self,
                            is: .range(0...),
                            required: true)
            validations.add("unit", as: String.self,
                            is: .count(1...),
                            required: true)       
        }
    }
                
}

extension Service {
    static var units: [String] {
        [
            "hour",
            "day",
            "week",
            "month",
            "year",
            "time"
        ]    
    }
}

//extension Service {
//     var category: Parent<Service, ServiceCategory> {
//         parent(\.$categoryId)
//     }
//}

/*

่json resposse
{
  "serviceId": "12345",
  "serviceName": "Yoga Class",
  "description": "A one-hour yoga class focusing on relaxation and flexibility.",
  "price": 20.00,
  "unit": "hour",
  "serviceCategory": {
    "categoryName": "Fitness",
    "subCategory": {
      "subCategoryName": "Yoga"
    }
  },
  "images": [
    "https://example.com/yoga-class-image1.jpg",
    "https://example.com/yoga-class-image2.jpg"
  ],
  "creationDate": "2024-04-30T12:00:00Z",
  "lastUpdated": "2024-05-02T15:30:00Z"
}


final class ServiceCategory: Model, Content {
    static let schema = "ServiceCategories"
    
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
            .init(name: "Transport")
        }
    }
}

extension ServiceCategory {
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
*/
