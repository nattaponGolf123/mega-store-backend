//
//  ServiceValidatorTests.swift
//
//
//  Created by IntrodexMac on 2/8/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class ServiceValidatorTests: XCTestCase {

    var app: Application!
    var validator: ServiceValidator!

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
        let content = ServiceRequest.Create(
            name: "Test",
            description: "A description",
            price: 99.99,
            unit: "kg",
            categoryId: UUID(),
            images: ["image1.jpg", "image2.jpg"],
            coverImage: "cover.jpg",
            tags: ["tag1", "tag2"]
        )
        let request = mockRequest(content: content)
        
        XCTAssertNoThrow(try validator.validateCreate(request))
    }

    func testValidateCreate_WithLessThan1CharName_ShouldThrow() {
        let content = ServiceRequest.Create(
            name: "",
            description: "A description",
            price: 99.99,
            unit: "kg",
            categoryId: UUID(),
            images: ["image1.jpg", "image2.jpg"],
            coverImage: "cover.jpg",
            tags: ["tag1", "tag2"]
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = ServiceRequest.Create(
            name: name,
            description: "A description",
            price: 99.99,
            unit: "kg",
            categoryId: UUID(),
            images: ["image1.jpg", "image2.jpg"],
            coverImage: "cover.jpg",
            tags: ["tag1", "tag2"]
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithNegativePrice_ShouldThrow() {
        let content = ServiceRequest.Create(
            name: "Test",
            description: "A description",
            price: -1.0,
            unit: "kg",
            categoryId: UUID(),
            images: ["image1.jpg", "image2.jpg"],
            coverImage: "cover.jpg",
            tags: ["tag1", "tag2"]
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    // MARK: - Update Tests

    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let content = ServiceRequest.Update(
            name: "Updated Test",
            description: "An updated description",
            price: 49.99,
            unit: "litre",
            categoryId: UUID(),
            images: ["image3.jpg"],
            coverImage: "cover_updated.jpg",
            tags: ["updated_tag1"]
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertNoThrow(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithLessThan1CharName_ShouldThrow() {
        let id = UUID()
        let content = ServiceRequest.Update(
            name: "",
            description: "An updated description",
            price: 49.99,
            unit: "litre",
            categoryId: UUID(),
            images: ["image3.jpg"],
            coverImage: "cover_updated.jpg",
            tags: ["updated_tag1"]
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithOver200CharName_ShouldThrow() {
        let id = UUID()
        let name = String(repeating: "A", count: 201)
        let content = ServiceRequest.Update(
            name: name,
            description: "An updated description",
            price: 49.99,
            unit: "litre",
            categoryId: UUID(),
            images: ["image3.jpg"],
            coverImage: "cover_updated.jpg",
            tags: ["updated_tag1"]
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithNegativePrice_ShouldThrow() {
        let id = UUID()
        let content = ServiceRequest.Update(
            name: "Updated Test",
            description: "An updated description",
            price: -1.0,
            unit: "litre",
            categoryId: UUID(),
            images: ["image3.jpg"],
            coverImage: "cover_updated.jpg",
            tags: ["updated_tag1"]
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    // MARK: - Fetch By ID Tests

    func testValidateID_WithValidRequest_ShouldReturnCorrectValues() {
        let id = UUID()
        let request = mockRequest(url: "/mock/:id",
                                  pathParameters: [
                                    "id": id
                                  ])

        XCTAssertNoThrow(try validator.validateID(request))
    }

    func testValidateID_WithInvalidID_ShouldThrow() {
        let request = mockGETRequest(url: "contacts/invalid")

        XCTAssertThrowsError(try validator.validateID(request))
    }

    // MARK: - Search Query Tests

    func testValidateSearchQuery_WithValidRequest_ShouldReturnCorrectValues() {
        let content = GeneralRequest.Search(query: "Test")
        let request = mockGETRequest(param: content)

        XCTAssertNoThrow(try validator.validateSearchQuery(request))
    }

    func testValidateSearchQuery_WithEmptyCharName_ShouldThrow() {
        let content = GeneralRequest.Search(query: "")
        let request = mockGETRequest(param: content)

        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }

    func testValidateSearchQuery_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = GeneralRequest.Search(query: name)
        let request = mockGETRequest(param: content)

        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }
    
}
