//
//  ServiceRepositoryTests.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import MockableTest

@testable import App

final class ProductRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    private(set) var productRepository: ProductRepository!
    private(set) var productCategoryRepository: ProductCategoryRepository!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ProductMigration())
        
        db = app.db
        
        productCategoryRepository = ProductCategoryRepository()
        productRepository = ProductRepository(productCategoryRepository: productCategoryRepository)
        
        try await dropCollection(db, schema: ProductCategory.schema)
        try await dropCollection(db, schema: Product.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Fetch All Tests

    func testFetchAll_WithCategory_ShouldReturnAllProducts() async throws {
        // Given
        let category = ProductCategory(name: "Category 1")
        try await category.create(on: db)
        
        let product1 = Product(number: 1, name: "Product1", description: "Desc1", unit: "kg", price: 100.0, categoryId: category.id)
        let product2 = Product(number: 2, name: "Product2", description: "Desc2", unit: "kg", price: 200.0)
        let product3 = Product(number: 3, name: "Product3", description: "Desc3", unit: "kg", price: 300.0, deletedAt: Date())
        try await product1.create(on: db)
        try await product2.create(on: db)
        try await product3.create(on: db)
        
        // When
        let result = try await productRepository.fetchAll(request: .init(), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Product1")
        XCTAssertEqual(result.items.first?.$category.id, category.id)
    }

    func testFetchAll_ShouldReturnAllProducts() async throws {
        // Given
        let product1 = Product(number: 1, name: "Product1", description: "Desc1", unit: "kg", price: 100.0)
        let product2 = Product(number: 2, name: "Product2", description: "Desc2", unit: "kg", price: 200.0, deletedAt: Date())
        try await product1.create(on: db)
        try await product2.create(on: db)
        
        // When
        let result = try await productRepository.fetchAll(request: .init(), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Product1")
    }
    
    func testFetchAll_WithShowDeleted_ShouldReturnDeletedProduct() async throws {
        // Given
        let product1 = Product(number: 1, name: "Product1", description: "Desc1", unit: "kg", price: 100.0)
        let product2 = Product(number: 2, name: "Product2", description: "Desc2", unit: "kg", price: 200.0, deletedAt: Date())
        try await product1.create(on: db)
        try await product2.create(on: db)
        
        // When
        let result = try await productRepository.fetchAll(request: .init(showDeleted: true), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    // MARK: - Fetch By ID Tests

    func testFetchById_ShouldReturnProduct() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        let result = try await productRepository.fetchById(request: .init(id: product.id!), on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Product")
    }
    
    func testFetchById_NotFound_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        do {
            _ = try await productRepository.fetchById(request: .init(id: UUID()), on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
        }
    }

    // MARK: - Create Tests

    func testCreate_ShouldCreateProduct() async throws {
        let category = ProductCategory(name: "Category 1")
        
        // Given
        try await category.save(on: db)
        
        let request = ProductRequest.Create(name: "Product",
                                            description: "Product description",
                                            price: 100.0,
                                            unit: "kg",
                                            categoryId: category.id,
                                            images: ["image1.jpg", "image2.jpg"],
                                            coverImage: "cover.jpg",
                                            manufacturer: "Manufacturer",
                                            barcode: "1234567890123",
                                            tags: ["tag1", "tag2"])
        
        // When
        let result = try await productRepository.create(request: request, on: db)
        
        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.number, 1)
        XCTAssertEqual(result.name, "Product")
        XCTAssertEqual(result.description!, "Product description")
        XCTAssertEqual(result.price, 100.0)
        XCTAssertEqual(result.unit, "kg")
        XCTAssertEqual(result.images.count, 2)
        XCTAssertEqual(result.coverImage, "cover.jpg")
        XCTAssertEqual(result.tags.count, 2)
        XCTAssertEqual(result.manufacturer, "Manufacturer")
        XCTAssertEqual(result.barcode, "1234567890123")
        XCTAssertEqual(result.$category.id, category.id)
    }
    
    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.Create(name: "Product", description: "Product description", price: 100.0, unit: "kg")
        
        // When
        do {
            _ = try await productRepository.create(request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }

    func testCreate_WithNonExistentCategoryId_ShouldThrowError() async throws {
        // Given
        let request = ProductRequest.Create(name: "Product", description: "Product description", price: 100.0, unit: "kg", categoryId: UUID())
        
        // When
        do {
            _ = try await productRepository.create(request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

    // MARK: - Update Tests

    func testUpdate_WithValidData_ShouldUpdateProduct() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.Update(name: "Updated Product",
                                            description: "Updated description",
                                            price: 200.0,
                                            unit: "grams",
                                            images: ["new_image1.jpg", "new_image2.jpg"],
                                            coverImage: "new_cover.jpg",
                                            manufacturer: "Updated Manufacturer",
                                            barcode: "0987654321098",
                                            tags: ["new_tag1", "new_tag2"])
        
        // When
        let result = try await productRepository.update(byId: .init(id: product.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.name, "Updated Product")
        XCTAssertEqual(result.description!, "Updated description")
        XCTAssertEqual(result.price, 200.0)
        XCTAssertEqual(result.unit, "grams")
        XCTAssertEqual(result.images.count, 2)
        XCTAssertEqual(result.coverImage, "new_cover.jpg")
        XCTAssertEqual(result.tags.count, 2)
        XCTAssertEqual(result.manufacturer, "Updated Manufacturer")
        XCTAssertEqual(result.barcode, "0987654321098")
    }

    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        // Given
        let product1 = Product(number: 1, name: "Product1", description: "Desc1", unit: "kg", price: 100.0)
        let product2 = Product(number: 2, name: "Product2", description: "Desc2", unit: "kg", price: 200.0)
        try await product1.create(on: db)
        try await product2.create(on: db)
        
        let request = ProductRequest.Update(name: "Product2")
        
        // When
        do {
            _ = try await productRepository.update(byId: .init(id: product1.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }

    func testUpdate_WithNonExistentCategoryId_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.Update(categoryId: UUID())
        
        // When
        do {
            _ = try await productRepository.update(byId: .init(id: product.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

    func testUpdate_WithCategoryId_ShouldUpdateProduct() async throws {
        // Given
        let category1 = ProductCategory(name: "Category1")
        let category2 = ProductCategory(name: "Category2")
        try await category1.create(on: db)
        try await category2.create(on: db)
        
        let product = Product(number: 1, name: "Product", description: "Desc", unit: "kg", price: 100.0, categoryId: category1.id!)
        try await product.create(on: db)

        let request = ProductRequest.Update(categoryId: category2.id)
        
        // When
        let result = try await productRepository.update(byId: .init(id: product.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.$category.id, category2.id)
    }
    
    // MARK: - Delete Tests

    func testDelete_ShouldMarkProductAsDeleted() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        let result = try await productRepository.delete(byId: .init(id: product.id!), on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
    
    // MARK: - Search Tests

    func testSearch_WithName_ShouldReturnProduct() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = GeneralRequest.Search(query: "Product")
        
        // When
        let result = try await productRepository.search(request: request, on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Product")
    }
    
    func testSearch_WithNumber_ShouldReturnProduct() async throws {
        // Given
        let product = Product(number: 123, name: "Product", description: "Desc", unit: "kg", price: 100.0)
        try await product.create(on: db)
        
        let request = GeneralRequest.Search(query: "123")
        
        // When
        let result = try await productRepository.search(request: request, on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.number, 123)
    }
    
    // MARK: - Fetch Lasted Number Tests

    func testFetchLastedNumber_ShouldReturnLastNumber() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        let result = try await productRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 1)
    }
    
    func testFetchLastedNumber_WithDeleted_ShouldReturnLastNumber() async throws {
        // Given
        let product1 = Product(number: 1, name: "Product1", description: "Desc1", unit: "kg", price: 100.0)
        let product2 = Product(number: 2, name: "Product2", description: "Desc2", unit: "kg", price: 200.0, deletedAt: .init())
        try await product1.create(on: db)
        try await product2.create(on: db)
        
        // When
        let result = try await productRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 2)
    }
    
    func testFetchLastedNumber_WithEmptyProduct_ShouldReturnZero() async throws {
        // When
        let result = try await productRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 0)
    }
    
    // MARK: - Variant Tests

    func testFetchVariantLastedNumber_ShouldReturnLastVariantNumber() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let variant1 = ProductVariant(number: 1, name: "Variant1", price: 100.0)
        let variant2 = ProductVariant(number: 2, name: "Variant2", price: 150.0)
        product.variants = [variant1, variant2]
        try await product.save(on: db)
        
        // When
        let result = try await productRepository.fetchVariantLastedNumber(byId: .init(id: product.id!), on: db)
        
        // Then
        XCTAssertEqual(result, 2)
    }

    func testFetchVariantLastedNumber_WithNoVariants_ShouldReturnZero() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        let result = try await productRepository.fetchVariantLastedNumber(byId: .init(id: product.id!), on: db)
        
        // Then
        XCTAssertEqual(result, 0)
    }

    func testCreateVariant_ShouldCreateVariant() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.CreateVariant(
            name: "Variant1",
            sku: "VAR-001", 
            price: 150.0,
            description: "Variant description",
            image: "variant.jpg",
            color: "Red",
            barcode: "1234567890123"
        )
        
        // When
        let result = try await productRepository.createVariant(byId: .init(id: product.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.variants.count, 1)
        XCTAssertEqual(result.variants.first?.name, "Variant1")
        XCTAssertEqual(result.variants.first?.price, 150.0)
        XCTAssertEqual(result.variants.first?.sku, "VAR-001")
        XCTAssertEqual(result.variants.first?.color, "Red")
    }

    func testCreateVariant_WithDuplicateVariantName_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let variant1 = ProductVariant(number: 1, name: "Variant1", price: 150.0)
        product.variants = [variant1]
        try await product.save(on: db)
        
        let request = ProductRequest.CreateVariant(
            name: "Variant1",
            sku: "VAR-002",
            price: 150.0,
            description: "Duplicate variant name",
            image: "variant.jpg",
            color: "Blue",
            barcode: "9876543210987"
        )
        
        // When
        do {
            _ = try await productRepository.createVariant(byId: .init(id: product.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }

    func testUpdateVariant_ShouldUpdateVariant() async throws {
        // Given
        let product = Stub.product
        let variant = ProductVariant(number: 1, name: "Variant1", price: 150.0, color: "Red")
        product.variants = [variant]
        try await product.create(on: db)
        
        let request = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            price: 200.0,
            description: "Updated variant description", 
            color: "Blue"
        )
        
        // When
        let result = try await productRepository.updateVariant(byId: .init(id: product.id!),
                                                               variantId: .init(id: variant.id!),
                                                               request: request, on: db)
        
        // Then
        XCTAssertEqual(result.variants.count, 1)
        XCTAssertEqual(result.variants.first?.name, "Updated Variant")
        XCTAssertEqual(result.variants.first?.price, 200.0)
        XCTAssertEqual(result.variants.first?.color, "Blue")
        
    }

    func testUpdateVariant_WithNonExistentVariant_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            price: 200.0,
            description: "Updated variant description", 
            color: "Blue"
        )
        
        // When
        do {
            _ = try await productRepository.updateVariant(byId: .init(id: product.id!), variantId: .init(id: UUID()), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }
    
    func testUpdateVariant_WithDeletedVariant_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        let variant = ProductVariant(number: 1, name: "Variant1", price: 150.0)
        variant.deletedAt = Date()
        product.variants = [variant]
        try await product.create(on: db)
        
        let request = ProductRequest.UpdateVariant(
            name: "Updated Variant",
            price: 200.0,
            description: "Updated variant description",
            color: "Blue"
        )
        
        // When
        do {
            _ = try await productRepository.updateVariant(byId: .init(id: product.id!), variantId: .init(id: variant.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }
    
    func testUpdateVariant_WithDuplicateVariantName_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        let variant1 = ProductVariant(number: 1, name: "Variant1", price: 150.0)
        let variant2 = ProductVariant(number: 2, name: "Variant2", price: 200.0)
        product.variants = [variant1, variant2]
        try await product.create(on: db)
        
        let request = ProductRequest.UpdateVariant(
            name: "Variant2",
            price: 200.0,
            description: "Updated variant description",
            color: "Blue"
        )
        
        // When
        do {
            _ = try await productRepository.updateVariant(byId: .init(id: product.id!), variantId: .init(id: variant1.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testUpdateVariant_WithNotFoundVariant_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        let request = ProductRequest.UpdateVariant(
            name: "Variant2",
            price: 200.0,
            description: "Updated variant description",
            color: "Blue"
        )
        
        // When
        do {
            _ = try await productRepository.updateVariant(byId: .init(id: product.id!), variantId: .init(id: UUID()), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

    func testDeleteVariant_ShouldMarkVariantAsDeleted() async throws {
        // Given
        let product = Stub.product
        let variant = ProductVariant(number: 1, name: "Variant1", price: 150.0)
        product.variants = [variant]
        try await product.create(on: db)
        
        // When
        let result = try await productRepository.deleteVariant(byId: .init(id: product.id!), variantId: .init(id: variant.id!), on: db)
        
        // Then
        XCTAssertNotNil(result.variants.first?.deletedAt)
    }

    func testDeleteVariant_WithNonExistentVariant_ShouldThrowError() async throws {
        // Given
        let product = Stub.product
        try await product.create(on: db)
        
        // When
        do {
            _ = try await productRepository.deleteVariant(byId: .init(id: product.id!), variantId: .init(id: UUID()), on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

}

// MARK: - Stub Data

private extension ProductRepositoryTests {
    struct Stub {
        static var group40: [Product] {
            (0..<40).map { Product(number: $0 + 1,
                                   name: "Product\($0)",
                                   description: "Desc\($0)",
                                   unit: "kg", 
                                   price: 100.0) }
        }
        
        static var product: Product {
            Product(number: 1, name: "Product", description: "Desc", unit: "kg", price: 100.0)
        }
        
        static var productCategory: ProductCategory {
            ProductCategory(name: "Category")
        }
    }
}

/*
 import Foundation
 import Vapor
 import Fluent
 import Mockable

 @Mockable
 protocol ProductRepositoryProtocol {
     typealias FetchAll = GeneralRequest.FetchAll
     typealias Search = GeneralRequest.Search
     
     typealias CreateVariant = (id: GeneralRequest.FetchById, content: ProductRequest.CreateVariant)
     typealias UpdateVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById, content: ProductRequest.UpdateVariant)
     typealias DeleteVariant = (id: GeneralRequest.FetchById, variantId: GeneralRequest.FetchById)
     
     func fetchAll(request: FetchAll,
                   on db: Database) async throws -> PaginatedResponse<Product>
     func fetchById(request: GeneralRequest.FetchById,
                   on db: Database) async throws -> Product
     func fetchByName(request: GeneralRequest.FetchByName,
                      on db: Database) async throws -> Product
     
     func create(request: ProductRequest.Create,
                 on db: Database) async throws -> Product
     func update(byId: GeneralRequest.FetchById,
                 request: ProductRequest.Update,
                 on db: Database) async throws -> Product
     func delete(byId: GeneralRequest.FetchById,
                 on db: Database) async throws -> Product
     
     func search(request: Search,
                 on db: Database) async throws -> PaginatedResponse<Product>
     
     func fetchLastedNumber(on db: Database) async throws -> Int
     
     func fetchVariantLastedNumber(byId: GeneralRequest.FetchById,
                                   on db: Database) async throws -> Int
     func createVariant(byId: GeneralRequest.FetchById,
                        request: ProductRequest.CreateVariant,
                        on db: Database) async throws -> Product
     func updateVariant(byId: GeneralRequest.FetchById,
                        variantId: GeneralRequest.FetchById,
                        request: ProductRequest.UpdateVariant,
                        on db: Database) async throws -> Product
     func deleteVariant(byId: GeneralRequest.FetchById,
                        variantId: GeneralRequest.FetchById,
                        on db: Database) async throws -> Product

 }

 class ProductRepository: ProductRepositoryProtocol {
     
     private var productCategoryRepository: ProductCategoryRepositoryProtocol
     
     init(productCategoryRepository: ProductCategoryRepositoryProtocol = ProductCategoryRepository()) {
         self.productCategoryRepository = productCategoryRepository
     }
     
     func fetchAll(request: FetchAll,
                   on db: any FluentKit.Database) async throws -> PaginatedResponse<Product> {
         let query = Product.query(on: db)
         
         if request.showDeleted {
             query.withDeleted()
         } else {
             query.filter(\.$deletedAt == nil)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(query: query,
                                         sortBy: request.sortBy,
                                         sortOrder: request.sortOrder,
                                         page: request.page,
                                         perPage: request.perPage)
         
         let response = PaginatedResponse(page: request.page,
                                          perPage: request.perPage,
                                          total: total,
                                          items: items)
         return response
     }
     
     func fetchById(request: GeneralRequest.FetchById,
                   on db: any FluentKit.Database) async throws -> Product {
         guard
             let found = try await Product.query(on: db).filter(\.$id == request.id).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func fetchByName(request: GeneralRequest.FetchByName, on db: any FluentKit.Database) async throws -> Product {
         guard
             let found = try await Product.query(on: db).filter(\.$name == request.name).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func create(request: ProductRequest.Create,
                 on db: any FluentKit.Database) async throws -> Product {
         // prevent duplicate name
         if let _ = try? await fetchByName(request: .init(name: request.name),
                                           on: db) {
             throw CommonError.duplicateName
         }
         
         if let groupId = request.categoryId {
             guard
                 let _ = try? await productCategoryRepository.fetchById(request: .init(id: groupId),
                                                                        on: db)
             else { throw DefaultError.notFound }
         }
         
         let lastedNumber = try await fetchLastedNumber(on: db)
         let nextNumber = lastedNumber + 1
         
         let product = Product(number: nextNumber,
                               name: request.name,
                               description: request.description,
                               unit: request.unit,
                               price: request.price,
                               categoryId: request.categoryId,
                               manufacturer: request.manufacturer,
                               barcode: request.barcode,
                               images: request.images,
                               coverImage: request.coverImage,
                               tags: request.tags)
         try await product.save(on: db)
         return product
     }
     
     func update(byId: GeneralRequest.FetchById,
                 request: ProductRequest.Update,
                 on db: any FluentKit.Database) async throws -> Product {
         let product = try await fetchById(request: .init(id: byId.id),
                                           on: db)
         
         if let name = request.name {
             // prevent duplicate name
             if let _ = try? await fetchByName(request: .init(name: name),
                                               on: db) {
                 throw CommonError.duplicateName
             }
             
             product.name = name
         }
         
         if let categoryId = request.categoryId {
             // try to fetch category id to check is exist
             guard
                 let _ = try? await productCategoryRepository.fetchById(request: .init(id: categoryId),
                                                                    on: db)
             else { throw DefaultError.notFound }
             
             product.$category.id = categoryId
         }
         
         if let description = request.description {
             product.description = description
         }
         
         if let price = request.price {
             product.price = price
         }
         
         if let unit = request.unit {
             product.unit = unit
         }
         
         if let images = request.images {
             product.images = images
         }
         
         if let coverImage = request.coverImage {
             product.coverImage = coverImage
         }
         
         if let tags = request.tags {
             product.tags = tags
         }
         
         if let manufacturer = request.manufacturer {
             product.manufacturer = manufacturer
         }
         
         if let barcode = request.barcode {
             product.barcode = barcode
         }
         
         try await product.save(on: db)
         return product
     }
     
     func delete(byId: GeneralRequest.FetchById,
                 on db: any FluentKit.Database) async throws -> Product {
         let product = try await fetchById(request: .init(id: byId.id),
                                         on: db)
         try await product.delete(on: db)
         return product
     }
     
     func search(request: Search,
                 on db: any FluentKit.Database) async throws -> PaginatedResponse<Product> {
         let q = request.query
         let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
         let query = Product.query(on: db).group(.or) { or in
             or.filter(\.$name =~ regexPattern)
             if let number = Int(q) {
                 or.filter(\.$number == number)
             }
             or.filter(\.$description =~ regexPattern)
             or.filter(\.$barcode == q)
             or.filter(\.$manufacturer =~ regexPattern)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(query: query,
                                         sortBy: request.sortBy,
                                         sortOrder: request.sortOrder,
                                         page: request.page,
                                         perPage: request.perPage)
         
         let response = PaginatedResponse(page: request.page,
                                          perPage: request.perPage,
                                          total: total,
                                          items: items)
         return response
     }
     
     func fetchLastedNumber(on db: any FluentKit.Database) async throws -> Int {
         let query = Product.query(on: db).withDeleted()
         query.sort(\.$number, .descending)
         query.limit(1)
         
         let model = try await query.first()
         
         return model?.number ?? 0
     }
     
     // MARK: Variant
     
     func fetchVariantLastedNumber(byId: GeneralRequest.FetchById,
                                   on db: any FluentKit.Database) async throws -> Int {
         let model = try await fetchById(request: .init(id: byId.id),
                                           on: db)
         
         let variants: [ProductVariant] = model.variants
         let lastedNumber = variants.map { $0.number }.max() ?? 0
         
         return lastedNumber
     }
     
     func createVariant(byId: GeneralRequest.FetchById,
                        request: ProductRequest.CreateVariant,
                        on db: any FluentKit.Database) async throws -> Product {
         let model = try await fetchById(request: .init(id: byId.id),
                                         on: db)
         
         let variantLastedNumber = try await fetchVariantLastedNumber(byId: byId,
                                                                      on: db)
         let nextNumber = variantLastedNumber + 1
         
         let existModels = model.variants.filter({$0.deletedAt == nil })
         
         // prevent duplicate name
         if existModels.contains(where: { $0.name == request.name }) {
             throw CommonError.duplicateName
         }
         
         //prevent duplicate color
         if existModels.contains(where: { $0.color == request.color }) {
             throw CommonError.duplicateColor
         }
         
         let variant = ProductVariant(number: nextNumber,
                                      name: request.name,
                                      sku: request.sku,
                                      price: request.price,
                                      description: request.description,
                                      image: request.image,
                                      color: request.color,
                                      barcode: request.barcode,
                                      dimensions: request.dimensions)
         model.variants.append(variant)
         
         try await model.save(on: db)
         return model
     }
     
     func updateVariant(byId: GeneralRequest.FetchById,
                        variantId: GeneralRequest.FetchById,
                        request: ProductRequest.UpdateVariant,
                        on db: any FluentKit.Database) async throws -> Product {
         let model = try await fetchById(request: .init(id: byId.id),
                                         on: db)
         
         let existModels = model.variants.filter({$0.deletedAt == nil })
         
         guard let variant = existModels.first(where: { $0.id == variantId.id }) else {
             throw DefaultError.notFound
         }
         
         // check is deleted
         if variant.deletedAt != nil {
             throw DefaultError.notFound
         }
         
         if let name = request.name {
             // prevent duplicate name
             if existModels.contains(where: { $0.name == name }) {
                 throw CommonError.duplicateName
             }
             
             variant.name = name
         }
         
         if let sku = request.sku {
             variant.sku = sku
         }
         
         if let price = request.price {
             variant.price = price
         }
         
         if let description = request.description {
             variant.description = description
         }
         
         if let image = request.image {
             variant.image = image
         }
         
         if let color = request.color {
             variant.color = color
         }
         
         if let barcode = request.barcode {
             variant.barcode = barcode
         }
         
         if let dimensions = request.dimensions {
             variant.dimensions = dimensions
         }
         
         try await model.save(on: db)
         return model
     }
     
     func deleteVariant(byId: GeneralRequest.FetchById,
                        variantId: GeneralRequest.FetchById,
                        on db: any FluentKit.Database) async throws -> Product {
         let model = try await fetchById(request: byId,
                                         on: db)
         
         let existModels = model.variants.filter({$0.deletedAt == nil })
         
         guard let variant = existModels.first(where: { $0.id == variantId.id }) else {
             throw DefaultError.notFound
         }
         
         // soft delete
         variant.updatedAt = Date()
         variant.deletedAt = Date()
         
         try await model.save(on: db)
         return model
     }
     
 }


 private extension ProductRepository {
     func sortQuery(query: QueryBuilder<Product>,
                    sortBy: SortBy,
                    sortOrder: SortOrder,
                    page: Int,
                    perPage: Int) async throws -> [Product] {
         
         let pageIndex = (page - 1)
         let pageStart = pageIndex * perPage
         let pageEnd = pageStart + perPage
         
         let range = pageStart..<pageEnd
                         
         query.with(\.$category)
         
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .number:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
             case .desc:
                 return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
             }
         case .groupName:
             switch sortOrder {
             case .asc:
                 return try await query.sort(ServiceCategory.self, \.$name).range(range).all()
             case .desc:
                 return try await query.sort(ServiceCategory.self, \.$name, .descending).range(range).all()
             }
         default:
             return try await query.range(range).all()
         }
     }
 }


 */
