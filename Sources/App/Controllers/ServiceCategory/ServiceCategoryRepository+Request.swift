import Foundation
import Vapor
import Fluent
import FluentMongoDriver

extension ServiceCategoryRepository { 

    enum SortBy: String, Codable {
        case name        
        case createdAt = "created_at"
    }
    
    enum SortByOrder: String, Codable {
        case asc
        case desc
    }
    
    struct Fetch: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortByOrder: SortByOrder

        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .name,
             sortByOrder: SortByOrder = .asc) {
            self.showDeleted = showDeleted
            self.page = page
            self.perPage = perPage
            self.sortBy = sortBy
            self.sortByOrder = sortByOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decode(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .name
            self.sortByOrder = (try? container.decode(SortByOrder.self, forKey: .sortByOrder)) ?? .asc
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortByOrder, forKey: .sortByOrder)
        }

        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page = "page"
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortByOrder = "sort_by_order"
        }
    }   

    struct Search: Content {
        let name: String
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortByOrder: SortByOrder

        init(name: String,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .name,
             sortByOrder: SortByOrder = .asc) {
            self.name = name
            self.page = page
            self.perPage = perPage
            self.sortBy = sortBy
            self.sortByOrder = sortByOrder
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .name
            self.sortByOrder = (try? container.decode(SortByOrder.self, forKey: .sortByOrder)) ?? .asc
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortByOrder, forKey: .sortByOrder)
        }

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case page = "page"
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortByOrder = "sort_by_order"
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
