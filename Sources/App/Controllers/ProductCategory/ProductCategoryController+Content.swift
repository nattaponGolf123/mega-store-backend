//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

extension ProductCategoryController {
    
    struct Query: Content {
        let name: String?
    }

//    struct RequestContent: Content {
//        let id: Int
//        
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let _id = try container.decode(String.self,
//                                           forKey: .id)
//            guard
//                let id = Int(_id)
//            else { throw Abort(.badRequest) }
//            
//            self.id = id
//        }
//    }

    struct CreateContent: Content, Validatable {
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

    struct UpdateContent: Content, Validatable {
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
