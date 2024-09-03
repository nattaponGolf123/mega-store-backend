//
//  File.swift
//
//
//  Created by IntrodexMac on 29/7/2567 BE.
//

import Foundation
import Vapor

struct GeneralRequest {
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
    
    struct FetchByTaxNumber: Content {
        let taxNumber: String
        
        init(taxNumber: String) {
            self.taxNumber = taxNumber
        }
    }
    
    struct FetchAll: Content {
        let showDeleted: Bool
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        
        static let minPageRange: (min: Int, max: Int) = (1, .max)
        static let perPageRange: (min: Int, max: Int) = (20, 1000)
        
        init(showDeleted: Bool = false,
             page: Int = Self.minPageRange.min,
             perPage: Int = Self.perPageRange.min,
             sortBy: SortBy = .createdAt,
             sortOrder: SortOrder = .asc) {
            self.showDeleted = showDeleted
            self.page = min(max(page, Self.minPageRange.min), Self.minPageRange.max)
            self.perPage = min(max(perPage, Self.perPageRange.min), Self.perPageRange.max)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showDeleted = (try? container.decodeIfPresent(Bool.self, forKey: .showDeleted)) ?? false
            self.page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? Self.minPageRange.min
            self.perPage = (try? container.decodeIfPresent(Int.self, forKey: .perPage)) ?? Self.perPageRange.min
            self.sortBy = (try? container.decodeIfPresent(SortBy.self, forKey: .sortBy)) ?? .createdAt
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
    
    struct Search: Content, Validatable {
        let query: String
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        
        static let minPageRange: (min: Int, max: Int) = (1, .max)
        static let perPageRange: (min: Int, max: Int) = (20, 1000)
        
        init(query: String,
             page: Int = Self.minPageRange.min,
             perPage: Int = Self.perPageRange.min,
             sortBy: SortBy = .createdAt,
             sortOrder: SortOrder = .asc) {
            self.query = query
            self.page = min(max(page, Self.minPageRange.min), Self.minPageRange.max)
            self.perPage = min(max(perPage, Self.perPageRange.min), Self.perPageRange.max)
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.query = try container.decode(String.self, forKey: .query)
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? Self.minPageRange.min
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? Self.perPageRange.min
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .createdAt
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
        
        static func validations(_ validations: inout Validations) {
            validations.add("q", as: String.self,
                            is: .count(1...200),
                            required: true)
        }
    }
    
//    struct FetchAll<T: Sortable>: Content {
//        let showDeleted: Bool
//        let page: Int
//        let perPage: Int
//        let sortBy: T
//        let sortOrder: SortOrder
//        
//        init(showDeleted: Bool = false,
//             page: Int = 1,
//             perPage: Int = 20,
//             sortBy: T = SortBy.createdAt as! T,
//             sortOrder: SortOrder = .asc) {
//            self.showDeleted = showDeleted
//            self.page = max(page, 1)
//            self.perPage = max(perPage, 20)
//            self.sortBy = sortBy
//            self.sortOrder = sortOrder
//        }
//        
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.showDeleted = (try? container.decodeIfPresent(Bool.self, forKey: .showDeleted)) ?? false
//            self.page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? 1
//            self.perPage = (try? container.decodeIfPresent(Int.self, forKey: .perPage)) ?? 20
//            //self.sortBy = try container.decode(T.self, forKey: .sortBy)
//            self.sortBy = (try? container.decodeIfPresent(T.self, forKey: .sortBy)) ?? SortBy.createdAt as! T
//            self.sortOrder = (try? container.decodeIfPresent(SortOrder.self, forKey: .sortOrder)) ?? .asc
//        }
//        
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(showDeleted, forKey: .showDeleted)
//            try container.encode(page, forKey: .page)
//            try container.encode(perPage, forKey: .perPage)
//            try container.encode(sortBy, forKey: .sortBy)
//            try container.encode(sortOrder, forKey: .sortOrder)
//        }
//        
//        enum CodingKeys: String, CodingKey {
//            case showDeleted = "show_deleted"
//            case page
//            case perPage = "per_page"
//            case sortBy = "sort_by"
//            case sortOrder = "sort_order"
//        }
//    }
    
//    struct Search<T: Sortable>: Content, Validatable {
//        let query: String
//        let page: Int
//        let perPage: Int
//        let sortBy: T
//        let sortOrder: SortOrder
//        
//        init(query: String,
//             page: Int = 1,
//             perPage: Int = 20,
//             sortBy: T = SortBy.createdAt as! T,
//             sortOrder: SortOrder = .asc) {
//            self.query = query
//            self.page = max(page, 1)
//            self.perPage = max(perPage, 20)
//            self.sortBy = sortBy
//            self.sortOrder = sortOrder
//        }
//        
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.query = try container.decode(String.self, forKey: .query)
//            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
//            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
//            //self.sortBy = try container.decode(T.self, forKey: .sortBy)
//            self.sortBy = (try? container.decodeIfPresent(T.self, forKey: .sortBy)) ?? SortBy.createdAt as! T
//            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
//        }
//        
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(query, forKey: .query)
//            try container.encode(page, forKey: .page)
//            try container.encode(perPage, forKey: .perPage)
//            try container.encode(sortBy as? SortBy, forKey: .sortBy)
//            try container.encode(sortOrder, forKey: .sortOrder)
//        }
//        
//        enum CodingKeys: String, CodingKey {
//            case query = "q"
//            case page
//            case perPage = "per_page"
//            case sortBy = "sort_by"
//            case sortOrder = "sort_order"
//        }
//        
//        static func validations(_ validations: inout Validations) {
//            validations.add("q", as: String.self,
//                            is: .count(1...200),
//                            required: true)
//        }
//    }
}

