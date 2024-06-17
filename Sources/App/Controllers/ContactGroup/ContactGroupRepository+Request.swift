import Foundation
import Vapor
import Fluent
import FluentMongoDriver

extension ContactGroupRepository { 

    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int

        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20) {
            self.showDeleted = showDeleted
            self.page = page
            self.perPage = perPage
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }

        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page = "page"
            case perPage = "per_page"
        }
    }   

    struct Search: Content {
        let name: String
        let page: Int
        let perPage: Int

        init(name: String,
             page: Int = 1,
             perPage: Int = 20) {
            self.name = name
            self.page = page
            self.perPage = perPage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
        }

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case page = "page"
            case perPage = "per_page"
        }
    }

    struct Create: Content, Validatable {
        let name: String
        let description: String?
        
        init(name: String,
             description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self,
                                             forKey: .name)
            self.description = try? container.decode(String.self,
                                                    forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
                
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        
        init(name: String? = nil,
            description: String? = nil) {
            self.name = name
            self.description = description
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case description = "description"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
}
