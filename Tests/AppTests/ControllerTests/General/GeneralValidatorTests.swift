//
//  GeneralValidatorTests.swift
//  
//
//  Created by IntrodexMac on 4/9/2567 BE.
//
import XCTest
import Vapor
@testable import App

final class GeneralValidatorTests: XCTestCase {
    
    var app: Application!
    var validator: GeneralValidator!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        
        validator = .init()
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: validateID
    func testValidateID_WithValidUUID_ShouldReturnFetchById() throws {
        // Given
        let uuid = UUID()
        let req = Request(application: app,
                          method: .GET,
                          url: URI(string: "/\(uuid)"),
                          on: app.eventLoopGroup.next())
        req.parameters.set("id", to: uuid.uuidString)
        
        // When
        let result = try validator.validateID(req)
        
        // Then
        XCTAssertEqual(result.id, uuid)
    }
    
    func testValidateID_WithInvalidUUID_ShouldThrowInvalidInputError() throws {
        // Given
        let req = Request(application: app, method: .GET, url: URI(string: "/invalid-uuid"), on: app.eventLoopGroup.next())
        
        // When / Then
        XCTAssertThrowsError(try validator.validateID(req)) { error in
            XCTAssertEqual(error as? DefaultError, .invalidInput)
        }
    }
    
    // MARK: validateSearchQuery
    func testValidateSearchQuery_WithValidQuery_ShouldReturnSearch() throws {
        // Given
        let content = GeneralRequest.Search(query: "test")
        let request = mockGETRequest(url: "/search",
                                     param: content)
        // When
        let result = try validator.validateSearchQuery(request)
        
        // Then
        XCTAssertEqual(result.query, content.query)
        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(result.perPage, 20)
        XCTAssertEqual(result.sortBy, .createdAt)
        XCTAssertEqual(result.sortOrder, .asc)
    }
    
    func testValidateSearchQuery_WithEmptyQuery_ShouldThrowInvalidInputError() throws {
        // Given
        let content = GeneralRequest.Search(query: "")
        let request = mockGETRequest(url: "/search",
                                     param: content)
        
        // When / Then
        do {
            let _ = try validator.validateSearchQuery(request)
            XCTFail("Expected error to be thrown")
        } catch {
            // do nothing
        }
    }
    
}
