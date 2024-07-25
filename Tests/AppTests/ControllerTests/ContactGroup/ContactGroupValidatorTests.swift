//
//  ContactGroupValidatorTests.swift
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

final class ContactGroupValidatorTests: XCTestCase {
    
    var app: Application!
    
    var validator: ContactGroupValidator!
    
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

    func testValidateCreate_WithValidRequest_ShouldReturnCorrectValues() {
        let content = ContactGroupRequest.Create(name: "Test")
        let request = mockPOSTRequest(content: content)
        
        XCTAssertNoThrow(try validator.validateCreate(request))
    }
    
    func testValidateCreate_WithLessThen3CharName_ShouldThrow() {
        let content = ContactGroupRequest.Create(name: "T")
        let request = mockPOSTRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateCreate(request))
    }
    
    func testValidateCreate_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = ContactGroupRequest.Create(name: name)
        let request = mockPOSTRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateCreate(request))
    }
              
    // MARK: Test - Update
    
    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let content = ContactGroupRequest.Update(name: "Test")
        let request = mockPOSTRequest(url: "/mock/:id",
                                      id: id,
                                      content: content)
        
        XCTAssertNoThrow(try validator.validateUpdate(request))
    }
    
    func testValidateUpdate_WithLessThen3CharName_ShouldThrow() {
        let content = ContactGroupRequest.Update(name: "T")
        let request = mockPOSTRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateUpdate(request))
    }
    
    func testValidateUpdate_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = ContactGroupRequest.Update(name: name)
        let request = mockPOSTRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    // MARK: - Fetch By ID Tests
    
    func testValidateID_WithValidRequest_ShouldReturnCorrectValues() {
        let content = ContactGroupRequest.FetchById(id: .init())
        let request = mockGETRequest(param: content)
        
        XCTAssertNoThrow(try validator.validateID(request))
    }
    
    func testValidateID_WithInvalidID_ShouldThrow() {
        let request = mockGETRequest(url: "contact_groups/invalid")
        
        XCTAssertThrowsError(try validator.validateID(request))
    }
    
    // MARK: - Search Query Tests
    typealias Search = ContactGroupRequest.Search
    
    func testValidateSearchQuery_WithValidRequest_ShouldReturnCorrectValues() {
        let content = Search(query: "Test")
        let request = mockGETRequest(param: content)
        
        XCTAssertNoThrow(try validator.validateSearchQuery(request))
    }
    
    func testValidateSearchQuery_WithEmptyCharName_ShouldThrow() {
        let content = Search(query: "")
        let request = mockGETRequest(param: content)
        
        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }
    
    func testValidateSearchQuery_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = Search(query: name)
        let request = mockGETRequest(param: content)
        
        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }
     
}

extension ContactGroupValidatorTests {
    
}

/*
 import Foundation
 import Vapor
 import Mockable

 @Mockable
 protocol ContactGroupValidatorProtocol {
     func validateCreate(_ req: Request) throws -> ContactGroupRequest.Create
     func validateUpdate(_ req: Request) throws -> (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)
     func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById
     func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search
 }

 class ContactGroupValidator: ContactGroupValidatorProtocol {
     typealias CreateContent = ContactGroupRequest.Create
     typealias UpdateContent = (id: ContactGroupRequest.FetchById, content: ContactGroupRequest.Update)

     func validateCreate(_ req: Request) throws -> CreateContent {
         try CreateContent.validate(content: req)
         
         return try req.content.decode(CreateContent.self)
     }

     func validateUpdate(_ req: Request) throws -> UpdateContent {
         try ContactGroupRequest.Update.validate(content: req)
         
         let id = try req.parameters.require("id", as: UUID.self)
         let fetchById = ContactGroupRequest.FetchById(id: id)
         let content = try req.content.decode(ContactGroupRequest.Update.self)
         
         return (fetchById, content)
     }

     func validateID(_ req: Request) throws -> ContactGroupRequest.FetchById {
         do {
             return try req.query.decode(ContactGroupRequest.FetchById.self)
         } catch {
             throw DefaultError.invalidInput
         }
     }

     func validateSearchQuery(_ req: Request) throws -> ContactGroupRequest.Search {
         do {
             let content = try req.query.decode(ContactGroupRequest.Search.self)
             
             guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
             
             return content
         }
         catch {
             throw DefaultError.invalidInput
         }
     }
 }

 */

/*
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
     
     struct Search: Content, Validatable {
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
         
         static func validations(_ validations: inout Validations) {
             validations.add("q", as: String.self,
                             is: .count(1...200))
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
         
         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(name, forKey: .name)
             try container.encode(description, forKey: .description)
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

 */
