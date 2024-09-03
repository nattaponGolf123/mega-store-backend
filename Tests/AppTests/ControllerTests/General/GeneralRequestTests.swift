//
//  GeneralRequestTests.swift
//  
//
//  Created by IntrodexMac on 4/9/2567 BE.
//
import XCTest
import Vapor
@testable import App

final class GeneralRequestTests: XCTestCase {
    
    // MARK: FetchById
    func testFetchById_ShouldInitializeWithId() {
        // Given
        let id = UUID()
        
        // When
        let request = GeneralRequest.FetchById(id: id)
        
        // Then
        XCTAssertEqual(request.id, id)
    }
    
    // MARK: FetchByName
    func testFetchByName_ShouldInitializeWithName() {
        // Given
        let name = "TestName"
        
        // When
        let request = GeneralRequest.FetchByName(name: name)
        
        // Then
        XCTAssertEqual(request.name, name)
    }
    
    // MARK: FetchByTaxNumber
    func testFetchByTaxNumber_ShouldInitializeWithTaxNumber() {
        // Given
        let taxNumber = "1234567890"
        
        // When
        let request = GeneralRequest.FetchByTaxNumber(taxNumber: taxNumber)
        
        // Then
        XCTAssertEqual(request.taxNumber, taxNumber)
    }
    
    // MARK: FetchAll
    func testFetchAll_ShouldInitializeWithDefaults() {
        // When
        let request = GeneralRequest.FetchAll()
        
        // Then
        XCTAssertEqual(request.showDeleted, false)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.perPage, 20)
        XCTAssertEqual(request.sortBy, .createdAt)
        XCTAssertEqual(request.sortOrder, .asc)
    }
    
    func testFetchAll_WithCustomValues_ShouldInitializeWithValues() {
        // Given
        let showDeleted = true
        let page = 2
        let perPage = 50
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.FetchAll(showDeleted: showDeleted,
                                              page: page,
                                              perPage: perPage,
                                              sortBy: sortBy,
                                              sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.showDeleted, showDeleted)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, perPage)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testFetchAll_WithLessPerPageValue_ShouldInitializeWithValues() {
        // Given
        let showDeleted = true
        let page = 3
        let perPage = 10
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.FetchAll(showDeleted: showDeleted,
                                              page: page,
                                              perPage: perPage,
                                              sortBy: sortBy,
                                              sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.showDeleted, showDeleted)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, 20)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testFetchAll_DecodeFromDecoder_ShouldInitializeWithValues() {
        // Given
        let showDeleted = true
        let page = 3
        let perPage = 10
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        let json = """
        {
            "show_deleted": true,
            "page": 3,
            "per_page": 10,
            "sort_by": "name",
            "sort_order": "desc"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let request = try! decoder.decode(GeneralRequest.FetchAll.self, from: json)
        
        // Then
        XCTAssertEqual(request.showDeleted, showDeleted)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, perPage)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testFetchAll_DecodeFromDecoder_ShouldInitializeWithDefaults() {
        // Given
        let json = """
        {
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let request = try! decoder.decode(GeneralRequest.FetchAll.self, from: json)
        
        // Then
        XCTAssertEqual(request.showDeleted, false)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.perPage, 20)
        XCTAssertEqual(request.sortBy, .createdAt)
        XCTAssertEqual(request.sortOrder, .asc)
    }
    
    // MARK: Search
    func testSearch_ShouldInitializeWithDefaults() {
        // Given
        let query = "TestQuery"
        
        // When
        let request = GeneralRequest.Search(query: query)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.perPage, 20)
        XCTAssertEqual(request.sortBy, .createdAt)
        XCTAssertEqual(request.sortOrder, .asc)
    }
    
    func testSearch_WithLessPerPageValue_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 3
        let perPage = 10
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.Search(query: query,
                                            page: page,
                                            perPage: perPage,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, 20)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testSearch_WithCustomValues_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 3
        let perPage = 90
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.Search(query: query,
                                            page: page,
                                            perPage: perPage,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, 90)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testSearch_WithOverPerPage_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 3
        let perPage = 9999
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.Search(query: query,
                                            page: page,
                                            perPage: perPage,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, 1000)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }

    func testSearch_WithLessPage_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 0
        let perPage = 90
        let sortBy = SortBy.name
        let sortOrder = SortOrder.desc
        
        // When
        let request = GeneralRequest.Search(query: query,
                                            page: page,
                                            perPage: perPage,
                                            sortBy: sortBy,
                                            sortOrder: sortOrder)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.perPage, 90)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    func testSearch_DecodeFromDecoder_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 3
        let perPage = 10
        let sortBy = SortBy.createdAt
        let sortOrder = SortOrder.desc
        let json = """
        {
            "q": "TestQuery",
            "page": 3,
            "per_page": 10,
            "sort_by": "created_at",
            "sort_order": "desc"
        }        
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let request = try! decoder.decode(GeneralRequest.Search.self, from: json)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, perPage)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
        
    }
    
    func testSearch_DecodeWithMissingParam_ShouldInitializeWithValues() {
        // Given
        let query = "TestQuery"
        let page = 1
        let perPage = 20
        let sortBy = SortBy.createdAt
        let sortOrder = SortOrder.asc
        let json = """
        {
            "q": "TestQuery"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let request = try! decoder.decode(GeneralRequest.Search.self, from: json)
        
        // Then
        XCTAssertEqual(request.query, query)
        XCTAssertEqual(request.page, page)
        XCTAssertEqual(request.perPage, perPage)
        XCTAssertEqual(request.sortBy, sortBy)
        XCTAssertEqual(request.sortOrder, sortOrder)
    }
    
    // MARK: Encoding/Decoding
    func testFetchAll_EncodingAndDecoding_ShouldBeEqual() throws {
        // Given
        let original = GeneralRequest.FetchAll(showDeleted: true, page: 3, perPage: 25, sortBy: .name, sortOrder: .desc)
        
        // When
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeneralRequest.FetchAll.self, from: data)
        
        // Then
        XCTAssertEqual(original.showDeleted, decoded.showDeleted)
        XCTAssertEqual(original.page, decoded.page)
        XCTAssertEqual(original.perPage, decoded.perPage)
        XCTAssertEqual(original.sortBy, decoded.sortBy)
        XCTAssertEqual(original.sortOrder, decoded.sortOrder)
    }
    
    func testSearch_EncodingAndDecoding_ShouldBeEqual() throws {
        // Given
        let original = GeneralRequest.Search(query: "TestQuery", page: 2, perPage: 30, sortBy: .name, sortOrder: .desc)
        
        // When
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GeneralRequest.Search.self, from: data)
        
        // Then
        XCTAssertEqual(original.query, decoded.query)
        XCTAssertEqual(original.page, decoded.page)
        XCTAssertEqual(original.perPage, decoded.perPage)
        XCTAssertEqual(original.sortBy, decoded.sortBy)
        XCTAssertEqual(original.sortOrder, decoded.sortOrder)
    }
}

/*
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


 */
