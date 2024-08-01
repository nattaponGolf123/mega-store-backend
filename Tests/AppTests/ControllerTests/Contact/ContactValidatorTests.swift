//
//  ContactValidatorTests.swift
//  
//
//  Created by IntrodexMac on 24/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class ContactValidatorTests: XCTestCase {
    
    var app: Application!
    
    var validator: ContactValidator!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
       
        validator = .init()
    }

    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Create Tests

//    func testValidateCreate_WithValidRequest_ShouldReturnCorrectValues() {
//        let content = ContactRequest.Create(name: "Test")
//        let request = mockRequest(content: content)
//        
//        XCTAssertNoThrow(try validator.validateCreate(request))
//    }
//    
//    func testValidateCreate_WithLessThen3CharName_ShouldThrow() {
//        let content = ContactRequest.Create(name: "T")
//        let request = mockRequest(content: content)
//        
//        XCTAssertThrowsError(try validator.validateCreate(request))
//    }
//    
//    func testValidateCreate_WithOver200CharName_ShouldThrow() {
//        let name = String(repeating: "A", count: 201)
//        let content = ContactRequest.Create(name: name)
//        let request = mockRequest(content: content)
//        
//        XCTAssertThrowsError(try validator.validateCreate(request))
//    }
//              
//    // MARK: Test - Update
//    
//    func testValidateUpdate_WithNoId_ShouldThrowError() {
//        let content = ContactRequest.Update(name: "Test")
//        let request = mockRequest(content: content)
//        
//        XCTAssertThrowsError(try validator.validateUpdate(request))
//    }
//        
//    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
//        let id = UUID()
//        let content = ContactRequest.Update(name: "Test")
//        let request = mockRequest(url: "/mock/:id",
//                                      id: id,
//                                      content: content)
//        
//        XCTAssertNoThrow(try validator.validateUpdate(request))
//    }
//    
//    func testValidateUpdate_WithLessThen3CharName_ShouldThrow() {
//        let id = UUID()
//        let content = ContactRequest.Update(name: "T")
//        let request = mockRequest(url: "/mock/:id",
//                                      id: id,
//                                      content: content)
//        
//        XCTAssertThrowsError(try validator.validateUpdate(request))
//    }
//    
//    func testValidateUpdate_WithOver200CharName_ShouldThrow() {
//        let id = UUID()
//        let name = String(repeating: "A", count: 201)
//        let content = ContactRequest.Update(name: name)
//        let request = mockRequest(url: "/mock/:id",
//                                      id: id,
//                                      content: content)
//        
//        XCTAssertThrowsError(try validator.validateUpdate(request))
//    }
//    
//    func testValidateUpdate_WithOnlyDescription_ShouldNotThrow() {
//        let id = UUID()
//        let content = ContactRequest.Update(description: "Test")
//        let request = mockRequest(url: "/mock/:id",
//                                      id: id,
//                                      content: content)
//        
//        XCTAssertNoThrow(try validator.validateUpdate(request))
//    }
//
//    // MARK: - Fetch By ID Tests
//    
//    func testValidateID_WithValidRequest_ShouldReturnCorrectValues() {
//        let content = ContactRequest.FetchById(id: .init())
//        let request = mockGETRequest(param: content)
//        
//        XCTAssertNoThrow(try validator.validateID(request))
//    }
//    
//    func testValidateID_WithInvalidID_ShouldThrow() {
//        let request = mockGETRequest(url: "contact_groups/invalid")
//        
//        XCTAssertThrowsError(try validator.validateID(request))
//    }
//    
//    // MARK: - Search Query Tests
//    typealias Search = ContactRequest.Search
//    
//    func testValidateSearchQuery_WithValidRequest_ShouldReturnCorrectValues() {
//        let content = Search(query: "Test")
//        let request = mockGETRequest(param: content)
//        
//        XCTAssertNoThrow(try validator.validateSearchQuery(request))
//    }
//    
//    func testValidateSearchQuery_WithEmptyCharName_ShouldThrow() {
//        let content = Search(query: "")
//        let request = mockGETRequest(param: content)
//        
//        XCTAssertThrowsError(try validator.validateSearchQuery(request))
//    }
//    
//    func testValidateSearchQuery_WithOver200CharName_ShouldThrow() {
//        let name = String(repeating: "A", count: 201)
//        let content = Search(query: name)
//        let request = mockGETRequest(param: content)
//        
//        XCTAssertThrowsError(try validator.validateSearchQuery(request))
//    }
     
}
