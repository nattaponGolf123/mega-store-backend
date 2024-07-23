import Foundation
import Vapor

struct ContactGroupRequest {
    
    struct FetchAll: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder

        init(showDeleted: Bool = false,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .name,
             sortOrder: SortOrder = .asc) {
            self.showDeleted = showDeleted
            self.page = max(page, 1)
            self.perPage = max(perPage, 20)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decodeIfPresent(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decodeIfPresent(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decodeIfPresent(SortBy.self, forKey: .sortBy)) ?? .name
            self.sortOrder = (try? container.decodeIfPresent(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(showDeleted, forKey: .showDeleted)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

        enum CodingKeys: String, CodingKey {
            case showDeleted = "show_deleted"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
        }
    }

    struct FetchById: Content {
        let id: UUID

        init(id: UUID) {
            self.id = id
        }
    }
    
    struct FetchByName: Content {
        let name: String

        init(name: String) {
            self.name = name
        }
    }
    
    struct Search: Content {
        let query: String
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder

        init(query: String,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .name,
             sortOrder: SortOrder = .asc) {
            self.query = query
            self.page = max(page, 1)
            self.perPage = max(perPage, 20)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.query = try container.decode(String.self, forKey: .query)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .name
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(query, forKey: .query)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
        }

        enum CodingKeys: String, CodingKey {
            case query = "q"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
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
            case name
            case description
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
            case name
            case description
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
        }
    }
}

extension ContactGroupRequest {
    enum SortBy: String, Codable {
        case name
        case createdAt = "created_at"
    }
    
    enum SortOrder: String, Codable {
        case asc
        case desc
    }
}
