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

final class ProductValidatorTests: XCTestCase {
    
    var app: Application!
    var validator: ProductValidator!

    override func setUp() async throws {
        try await super.setUp()

        app = Application(.testing)
        validator = .init()
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Test validateCreate
    
    func testValidateCreate_WithValidRequest_ShouldReturnCreateContent() throws {
        let content = ProductRequest.Create(
            name: "Test Product",
            description: "Test description",
            price: 100.0,
            unit: "kg",
            categoryId: UUID(),
            images: ["image1", "image2"],
            coverImage: "cover_image",
            manufacturer: "Test Manufacturer",
            barcode: "1234567890123",
            tags: ["tag1", "tag2"]
        )
        
        let request = mockRequest(content: content)
        
        //XCTAssertNoThrow(try validator.validateCreate(request))
                
        let result = try validator.validateCreate(request)
        
        XCTAssertEqual(result.name, "Test Product")
        XCTAssertEqual(result.price, 100.0)
        XCTAssertEqual(result.unit, "kg")
        XCTAssertEqual(result.images, ["image1", "image2"])
        XCTAssertEqual(result.coverImage, "cover_image")
    }
    
    // MARK: - Test validateUpdate
    
    func testValidateUpdate_WithValidRequest_ShouldReturnUpdateContent() throws {
        let id = UUID()
        let content = ProductRequest.Update(
            name: "Updated Product",
            description: "Updated description",
            price: 150.0,
            unit: "liters",
            categoryId: UUID(),
            images: ["image3", "image4"],
            coverImage: "updated_cover_image",
            manufacturer: "Updated Manufacturer",
            barcode: "0987654321098",
            tags: ["tag3", "tag4"]
        )
        
        let request = mockRequest(url: "/mock/:id",
                                  pathParameters: ["id": id],
                                  content: content)
        
        let result = try validator.validateUpdate(request)
        
        XCTAssertEqual(result.content.name, "Updated Product")
        XCTAssertEqual(result.content.price, 150.0)
        XCTAssertEqual(result.content.unit, "liters")
        XCTAssertEqual(result.content.images, ["image3", "image4"])
        XCTAssertEqual(result.content.coverImage, "updated_cover_image")
    }

    // MARK: - Test validateCreateVariant
    
    func testValidateCreateVariant_WithValidRequest_ShouldReturnCreateVariantContent() throws {
        let id = UUID()
        let content = ProductRequest.CreateVariant(
            name: "Test Variant",
            sku: "SKU-001",
            price: 100.0,
            description: "Test variant description",
            image: "image_url",
            color: "red",
            barcode: "1234567890123"
        )
        
        let request = mockRequest(url: "/mock/:id/variants",
                                  pathParameters: ["id": id],
                                  content: content)
        
        let result = try validator.validateCreateVariant(request)
        
        XCTAssertEqual(result.content.name, "Test Variant")
        XCTAssertEqual(result.content.price, 100.0)
        XCTAssertEqual(result.content.sku, "SKU-001")
        XCTAssertEqual(result.content.color, "red")
        XCTAssertEqual(result.content.barcode, "1234567890123")
    }

    // MARK: - Test validateUpdateVariant
    
    func testValidateUpdateVariant_WithValidRequest_ShouldReturnUpdateVariantContent() throws {
        let productId = UUID()
        let variantId = UUID()
        let content = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            sku: "SKU-002",
            price: 150.0,
            description: "Updated variant description",
            image: "updated_image_url",
            color: "blue",
            barcode: "0987654321098"
        )
        
        let request = mockRequest(url: "/mock/:id/variants/:variant_id",
                                  pathParameters: ["id": productId,
                                                   "variant_id": variantId],
                                  content: content)
                
        let result = try validator.validateUpdateVariant(request)
        
        XCTAssertEqual(result.content.name, "Updated Variant")
        XCTAssertEqual(result.content.price, 150.0)
        XCTAssertEqual(result.content.sku, "SKU-002")
        XCTAssertEqual(result.content.color, "blue")
        XCTAssertEqual(result.content.barcode, "0987654321098")
    }

    // MARK: - Test validateDeleteVariant
    
    func testValidateDeleteVariant_WithValidRequest_ShouldReturnDeleteVariantContent() throws {
        let productId = UUID()
        let variantId = UUID()
        
        let request = mockRequest(url: "/mock/:id/variants/:variant_id",
                                  pathParameters: ["id": productId,
                                                   "variant_id": variantId])
        
        let result = try validator.validateDeleteVariant(request)
        
        XCTAssertEqual(result.id.id, productId)
        XCTAssertEqual(result.variantId.id, variantId)        
    }
}
