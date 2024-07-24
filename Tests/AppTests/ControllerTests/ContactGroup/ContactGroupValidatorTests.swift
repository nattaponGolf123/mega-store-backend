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
//        let req = Request(application: app, on: any EventLoop)
//        let validator = ContactGroupValidator()
//
//        let create = ContactGroupRequest.Create(
//            name: "Test",
//            description: "Test",
//            isDeleted: false
//        )
//
//        req.content.encode(create)
//
//        XCTAssertNoThrow(try validator.validateCreate(req))
    }

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
