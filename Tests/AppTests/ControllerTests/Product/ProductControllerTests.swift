//
//  ProductControllerTests.swift
//
//
//  Created by IntrodexMac on 23/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class ProductControllerTests: XCTestCase {

    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    var app: Application!
    var db: Database!
    
    // Mock repositories and validators
    lazy var productCategoryRepo = ProductCategoryRepository()
    lazy var repo = ProductRepository(productCategoryRepository: productCategoryRepo)
    lazy var validator = MockProductValidatorProtocol()
    lazy var generalValidator = MockGeneralValidatorProtocol()
    
    var controller: ProductController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        try configure(app,
                      dbHost: dbHost,
                      migration: ProductCategoryMigration())
        
        db = app.db
        
        // Register product controller
        controller = .init(repository: repo,
                           validator: validator,
                           generalValidator: generalValidator)
        try app.register(collection: controller)
        
        // Drop collections
        try await dropCollection(db,
                                 schema: ProductCategory.schema)
        try await dropCollection(db,
                                 schema: Product.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /products
    func testAll_WithNoRequestParam_ShouldReturnEmptyProducts() async throws {
        try app.test(.GET, "products") { res in
            XCTAssertEqual(res.status, .ok)
            let products = try res.content.decode(PaginatedResponse<ProductResponse>.self)
            XCTAssertEqual(products.items.count, 0)
        }
    }
    
    func testAll_WithValidRequest_ShouldReturnAllProducts() async throws {
        let category = ProductCategory(name: "C1")
        try await category.save(on: db)
        
        let product1 = Product(number: 1, name: "P1", description: "D1", unit: "kg", price: 100.0, categoryId: category.id)
        let product2 = Product(number: 2, name: "P2", description: "D2", unit: "kg", price: 150.0)
        try await product1.save(on: db)
        try await product2.save(on: db)
        
        try app.test(.GET, "products") { res in
            XCTAssertEqual(res.status, .ok)
            let products = try res.content.decode(PaginatedResponse<ProductResponse>.self)
            XCTAssertEqual(products.items.count, 2)
        }
    }
    
    // MARK: - Test GET /products/:id
    func testGetByID_WithInvalidID_ShouldReturnNotFound() async throws {
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(generalValidator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "products/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    func testGetByID_WithValidID_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0, images: [], coverImage: nil, tags: [])
        try await product.save(on: db)
        
        let request = GeneralRequest.FetchById(id: product.id!)
        given(generalValidator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "products/\(product.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.name, "Laptop")
        }
    }
    
    // MARK: - Test POST /products
    func testCreate_WithInvalidProduct_ShouldReturnBadRequest() async throws {
        let request = ProductRequest.Create(name: "", description: nil, price: 0, unit: "", categoryId: nil, images: [], coverImage: nil, tags: [])
        given(validator).validateCreate(.any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "products",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidProduct_ShouldReturnProduct() async throws {
        let category = ProductCategory(name: "C1")
        try await category.save(on: db)
        
        let request = ProductRequest.Create(name: "Laptop", description: "High-end laptop", price: 1000.0, unit: "piece", categoryId: category.id!, images: [], coverImage: nil, tags: [])
        given(validator).validateCreate(.any).willReturn(request)
        
        try app.test(.POST, "products",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.name, "Laptop")
        }
    }
    
    // MARK: - Test PUT /products/:id
    func testUpdate_WithValidProduct_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        try await product.save(on: db)
        
        let request = ProductRequest.Update(name: "Updated Laptop", price: 1200.0)
        let requestId = GeneralRequest.FetchById(id: product.id!)
        given(validator).validateUpdate(.any).willReturn((requestId, request))
        
        try app.test(.PUT, "products/\(product.id!.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.name, "Updated Laptop")
            XCTAssertEqual(productResponse.price, 1200.0)
        }
    }
    
    // MARK: - Test DELETE /products/:id
    func testDelete_WithValidProduct_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        try await product.save(on: db)
        
        let requestId = GeneralRequest.FetchById(id: product.id!)
        given(generalValidator).validateID(.any).willReturn(requestId)
        
        try app.test(.DELETE, "products/\(product.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.name, "Laptop")
        }
    }
    
    // MARK: - Test POST /products/:id/variants
    func testCreateVariant_WithValidVariant_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        try await product.save(on: db)
        
        let variantRequest = ProductRequest.CreateVariant(name: "Variant1", sku: "VAR-001", price: 1200.0, description: "Variant1", image: nil, color: "Black", barcode: nil, dimensions: nil)
        let requestId = GeneralRequest.FetchById(id: product.id!)
        given(validator).validateCreateVariant(.any).willReturn((requestId, variantRequest))
        
        try app.test(.POST, "products/\(product.id!.uuidString)/variants",
                     beforeRequest: { req in
            try req.content.encode(variantRequest)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.variants.count, 1)
            XCTAssertEqual(productResponse.variants.first?.name, "Variant1")
        }
    }
    
    // MARK: - Test PUT /products/:id/variants/:variant_id
    func testUpdateVariant_WithValidVariant_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        let variant = ProductVariant(number: 1, name: "Variant1", price: 1200.0, color: "Black")
        product.variants = [variant]
        try await product.save(on: db)
        
        let variantRequest = ProductRequest.UpdateVariant(name: "Updated Variant", price: 1300.0, color: "Red")
        let requestId = GeneralRequest.FetchById(id: product.id!)
        let variantId = GeneralRequest.FetchById(id: variant.id!)
        given(validator).validateUpdateVariant(.any).willReturn((requestId, variantId, variantRequest))
        
        try app.test(.PUT, "products/\(product.id!.uuidString)/variants/\(variant.id!.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(variantRequest)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.variants.first?.name, "Updated Variant")
            XCTAssertEqual(productResponse.variants.first?.price, 1300.0)
        }
    }
    
    // MARK: - Test DELETE /products/:id/variants/:variant_id
    func testDeleteVariant_WithValidVariant_ShouldReturnProduct() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        let variant = ProductVariant(number: 1, name: "Variant1", price: 1200.0, color: "Black")
        product.variants = [variant]
        try await product.save(on: db)
        
        let requestId = GeneralRequest.FetchById(id: product.id!)
        let variantId = GeneralRequest.FetchById(id: variant.id!)
        given(validator).validateDeleteVariant(.any).willReturn((requestId, variantId))
        
        try app.test(.DELETE, "products/\(product.id!.uuidString)/variants/\(variant.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let productResponse = try res.content.decode(ProductResponse.self)
            XCTAssertEqual(productResponse.variants.first?.deletedAt != nil, true)
        }
    }
    
    // MARK: - Test GET /products/search
    func testSearch_WithValidQuery_ShouldReturnProducts() async throws {
        let product = Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0)
        try await product.save(on: db)
        
        let query = Search(query: "Laptop")
        given(generalValidator).validateSearchQuery(.any).willReturn(query)
        
        try app.test(.GET, "products/search?query=Laptop") { res in
            XCTAssertEqual(res.status, .ok)
            let products = try res.content.decode(PaginatedResponse<ProductResponse>.self)
            XCTAssertEqual(products.items.count, 1)
            XCTAssertEqual(products.items.first?.name, "Laptop")
        }
    }
}

// MARK: - Stubs for Tests

extension ProductControllerTests {
    struct Stub {
        
        static var emptyPageProduct: PaginatedResponse<Product> {
            .init(page: 1, perPage: 10, total: 0, items: [])
        }
        
        static var pageProduct: PaginatedResponse<Product> {
            .init(page: 1, perPage: 10, total: 2, items: [
                Product(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0, images: [], coverImage: nil, tags: []),
                Product(number: 2, name: "Tablet", description: "Powerful tablet", unit: "piece", price: 800.0, images: [], coverImage: nil, tags: [])
            ])
        }
        
        static var product: Product {
            .init(number: 1, name: "Laptop", description: "High-end laptop", unit: "piece", price: 1000.0, images: [], coverImage: nil, tags: [])
        }
    }
}
