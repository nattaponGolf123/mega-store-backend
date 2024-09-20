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
            "sort_by": "NAME",
            "sort_order": "DESC"
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
            "sort_by": "CREATED_AT",
            "sort_order": "DESC"
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
