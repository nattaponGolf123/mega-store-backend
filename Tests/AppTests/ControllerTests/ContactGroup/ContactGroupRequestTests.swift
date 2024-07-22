//
//  ContactGroupRequestTests.swift
//  
//
//  Created by IntrodexMac on 23/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import MockableTest

@testable import App

final class ContactGroupRequestTests: XCTestCase {
    
    // MARK: - Fetch Tests
    
    func testFetchInit_WithDefaults_ShouldReturnCorrectValues() {
        let fetch = ContactGroupRequest.Fetch()
        
        XCTAssertFalse(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 1)
        XCTAssertEqual(fetch.perPage, 20)
        XCTAssertEqual(fetch.sortBy, .name)
        XCTAssertEqual(fetch.sortOrder, .asc)
    }

    func testFetchInit_WithCustomValues_ShouldReturnCorrectValues() {
        let fetch = ContactGroupRequest.Fetch(showDeleted: true, page: 2, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertTrue(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 2)
        XCTAssertEqual(fetch.perPage, 50)
        XCTAssertEqual(fetch.sortBy, .createdAt)
        XCTAssertEqual(fetch.sortOrder, .desc)
    }
    
    func testFetchInit_WithInvalidPage_ShouldReturnCorrectValues() {
        let fetch = ContactGroupRequest.Fetch(showDeleted: true, page: -1, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertTrue(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 1)
        XCTAssertEqual(fetch.perPage, 50)
        XCTAssertEqual(fetch.sortBy, .createdAt)
        XCTAssertEqual(fetch.sortOrder, .desc)
    }

    func testFetchInit_WithInvalidPerPage_ShouldReturnCorrectValues() {
        let fetch = ContactGroupRequest.Fetch(showDeleted: true, page: 2, perPage: -1, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertTrue(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 2)
        XCTAssertEqual(fetch.perPage, 20)
        XCTAssertEqual(fetch.sortBy, .createdAt)
        XCTAssertEqual(fetch.sortOrder, .desc)
    }
    
    func testFetchEncode_WithValidInstance_ShouldReturnJSON() throws {
        let fetch = ContactGroupRequest.Fetch(showDeleted: true, page: 2, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(fetch)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["show_deleted"] as? Bool, true)
        XCTAssertEqual(jsonObject?["page"] as? Int, 2)
        XCTAssertEqual(jsonObject?["per_page"] as? Int, 50)
        XCTAssertEqual(jsonObject?["sort_by"] as? String, "created_at")
        XCTAssertEqual(jsonObject?["sort_order"] as? String, "desc")
    }

    func testFetchDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "show_deleted": true,
            "page": 2,
            "per_page": 50,
            "sort_by": "created_at",
            "sort_order": "desc"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let fetch = try decoder.decode(ContactGroupRequest.Fetch.self, from: data)
        
        XCTAssertTrue(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 2)
        XCTAssertEqual(fetch.perPage, 50)
        XCTAssertEqual(fetch.sortBy, .createdAt)
        XCTAssertEqual(fetch.sortOrder, .desc)
    }
    
    func testFetchDecode_WithLessJSON_ShouldReturnInstance() throws {
        let json = """
        {

        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let fetch = try decoder.decode(ContactGroupRequest.Fetch.self, from: data)
        
        XCTAssertFalse(fetch.showDeleted)
        XCTAssertEqual(fetch.page, 1)
        XCTAssertEqual(fetch.perPage, 20)
        XCTAssertEqual(fetch.sortBy, .name)
        XCTAssertEqual(fetch.sortOrder, .asc)
    }

    // MARK: - Search Tests
    
    func testSearchInit_WithDefaults_ShouldReturnCorrectValues() {
        let search = ContactGroupRequest.Search(name: "Test")
        
        XCTAssertEqual(search.name, "Test")
        XCTAssertEqual(search.page, 1)
        XCTAssertEqual(search.perPage, 20)
        XCTAssertEqual(search.sortBy, .name)
        XCTAssertEqual(search.sortOrder, .asc)
    }

    func testSearchInit_WithCustomValues_ShouldReturnCorrectValues() {
        let search = ContactGroupRequest.Search(name: "Test", page: 2, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertEqual(search.name, "Test")
        XCTAssertEqual(search.page, 2)
        XCTAssertEqual(search.perPage, 50)
        XCTAssertEqual(search.sortBy, .createdAt)
        XCTAssertEqual(search.sortOrder, .desc)
    }

    func testSearchInit_WithInvalidPage_ShouldReturnCorrectValues() {
        let search = ContactGroupRequest.Search(name: "Test", page: -1, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertEqual(search.name, "Test")
        XCTAssertEqual(search.page, 1)
        XCTAssertEqual(search.perPage, 50)
        XCTAssertEqual(search.sortBy, .createdAt)
        XCTAssertEqual(search.sortOrder, .desc)
    }
    
    func testSearchInit_WithInvalidPerPage_ShouldReturnCorrectValues() {
        let search = ContactGroupRequest.Search(name: "Test", page: 2, perPage: -1, sortBy: .createdAt, sortOrder: .desc)
        
        XCTAssertEqual(search.name, "Test")
        XCTAssertEqual(search.page, 2)
        XCTAssertEqual(search.perPage, 20)
        XCTAssertEqual(search.sortBy, .createdAt)
        XCTAssertEqual(search.sortOrder, .desc)
    }
    
    func testSearchEncode_WithValidInstance_ShouldReturnJSON() throws {
        let search = ContactGroupRequest.Search(name: "Test", page: 2, perPage: 50, sortBy: .createdAt, sortOrder: .desc)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(search)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "Test")
        XCTAssertEqual(jsonObject?["page"] as? Int, 2)
        XCTAssertEqual(jsonObject?["per_page"] as? Int, 50)
        XCTAssertEqual(jsonObject?["sort_by"] as? String, "created_at")
        XCTAssertEqual(jsonObject?["sort_order"] as? String, "desc")
    }

    func testSearchDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "name": "Test",
            "page": 2,
            "per_page": 50,
            "sort_by": "created_at",
            "sort_order": "desc"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let search = try decoder.decode(ContactGroupRequest.Search.self, from: data)
        
        XCTAssertEqual(search.name, "Test")
        XCTAssertEqual(search.page, 2)
        XCTAssertEqual(search.perPage, 50)
        XCTAssertEqual(search.sortBy, .createdAt)
        XCTAssertEqual(search.sortOrder, .desc)
    }

    // MARK: - Create Tests
    
    func testCreateInit_WithDefaults_ShouldReturnCorrectValues() {
        let create = ContactGroupRequest.Create(name: "Group")
        
        XCTAssertEqual(create.name, "Group")
        XCTAssertNil(create.description)
    }

    func testCreateInit_WithCustomValues_ShouldReturnCorrectValues() {
        let create = ContactGroupRequest.Create(name: "Group", description: "Description")
        
        XCTAssertEqual(create.name, "Group")
        XCTAssertEqual(create.description, "Description")
    }

    // MARK: - Update Tests
    
    func testUpdateInit_WithDefaults_ShouldReturnCorrectValues() {
        let update = ContactGroupRequest.Update()
        
        XCTAssertNil(update.name)
        XCTAssertNil(update.description)
    }

    func testUpdateInit_WithCustomValues_ShouldReturnCorrectValues() {
        let update = ContactGroupRequest.Update(name: "Group", description: "Description")
        
        XCTAssertEqual(update.name, "Group")
        XCTAssertEqual(update.description, "Description")
    }
}

