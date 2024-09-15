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

final class ServiceRepositoryTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    private(set) var serviceRepository: ServiceRepository!
    private(set) var serviceCategoryRepository: ServiceCategoryRepository!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: ServiceMigration())
        
        db = app.db
        
        serviceCategoryRepository = ServiceCategoryRepository()
        serviceRepository = ServiceRepository(serviceCategoryRepository: serviceCategoryRepository)
        
        try await dropCollection(db,
                                 schema: ServiceCategory.schema)
        try await dropCollection(db,
                                 schema: Service.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Fetch All Tests

    func testFetchAll_WithCategory_ShouldReturnAllServices() async throws {
        // Given
        let category = ServiceCategory(name: "Cate 1")
        try await category.create(on: db)
        
        let service1 = Service(number: 1,
                               name: "Service1",
                               description: "Desc1",
                               price: 100.0,
                               unit: "unit",
                               categoryId: category.id)
        let service2 = Service(number: 2, 
                               name: "Service2",
                               description: "Desc2",
                               price: 200.0,
                               unit: "unit")
        let service3 = Service(number: 3,
                               name: "Service3",
                               description: "Desc3",
                               price: 300.0,
                               unit: "unit",
                               deletedAt: Date())
        try await service1.create(on: db)
        try await service2.create(on: db)
        try await service3.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
        XCTAssertEqual(result.items.first?.$category.id, category.id)
    }
    
    func testFetchAll_ShouldReturnAllServices() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit",
                               deletedAt: Date())
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithShowDeleted_ShouldReturnDeletedService() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", deletedAt: Date())
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(showDeleted: true), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
    }
    
    func testFetchAll_WithPagination_ShouldReturnServices() async throws {
        // Given
        let services = Stub.group40
        try await services.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(page: 2, perPage: 25), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 15)
    }
    
    func testFetchAll_WithSortByNameDesc_ShouldReturnServicesInDescendingOrder() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .desc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service2")
    }
    
    func testFetchAll_WithSortByNameAsc_ShouldReturnServicesInAscendingOrder() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithSortByCreatedAtDesc_ShouldReturnServicesInDescendingOrderOfCreation() async throws {
        // Given
        let date = Date()
        let nextHour = date.addingTimeInterval(3600)
        let service1 = Service(number: 1,
                               name: "Service1",
                               description: "Desc1",
                               price: 100.0,
                               unit: "unit",
                               createdAt: date)
        let service2 = Service(number: 2, 
                               name: "Service2",
                               description: "Desc2",
                               price: 200.0,
                               unit: "unit",
                               createdAt: nextHour)
        try await service1.create(on: db)
        sleep(1)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .createdAt, 
                                                                         sortOrder: .desc),
                                                          on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service2")
    }
    
    func testFetchAll_WithSortByCreatedAtAsc_ShouldReturnServicesInAscendingOrderOfCreation() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        sleep(1)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithSortByCategoryNameDesc_ShouldReturnServicesInDescendingOrderOfCategoryName() async throws {
        // Given
        let category1 = ServiceCategory(name: "Category1")
        let category2 = ServiceCategory(name: "Category2")
        try await category1.create(on: db)
        try await category2.create(on: db)
        
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit", categoryId: category1.id!)
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", categoryId: category2.id!)
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .groupName, sortOrder: .desc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service2")
    }
    
    func testFetchAll_WithSortByCategoryNameAsc_ShouldReturnServicesInAscendingOrderOfCategoryName() async throws {
        // Given
        let category1 = ServiceCategory(name: "Category1")
        let category2 = ServiceCategory(name: "Category2")
        try await category1.create(on: db)
        try await category2.create(on: db)
        
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit", categoryId: category1.id!)
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", categoryId: category2.id!)
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .groupName, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
        
    func testFetchAll_WithSortByNumberAsc_ShouldReturnServicesInAscendingOrderOfNumber() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .number, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithSortByNumberDesc_ShouldReturnServicesInDescendingOrderOfNumber() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .number, sortOrder: .desc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service2")
    }

    // MARK: - Fetch By ID Tests

    func testFetchById_ShouldReturnService() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchById(request: .init(id: service.id!), on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Service")
    }
    
    func testFetchById_NotFound_ShouldThrowError() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        do {
            _ = try await serviceRepository.fetchById(request: .init(id: UUID()), on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
        }
    }
    
    // MARK: - Fetch By Name Tests

    func testFetchByName_ShouldReturnService() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchByName(request: .init(name: "Service"), on: db)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "Service")
    }
    
    func testFetchByName_ShouldThrowNotFound() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        do {
            _ = try await serviceRepository.fetchByName(request: .init(name: "Service1"), on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

    // MARK: - Create Tests

    func testCreate_ShouldCreateService() async throws {
        let category = ServiceCategory(name: "Category 1")
        
        // Given
        try await category.save(on: db)
//        given(serviceCategoryRepository).fetchById(request: .any,
//                                                   on: .any).willReturn(category)
        
        let request = ServiceRequest.Create(name: "Service",
                                            description: "Service description",
                                            price: 100.0,
                                            unit: "unit",
                                            categoryId: category.id,
                                            images: ["image1.jpg", "image2.jpg"],
                                            coverImage: "cover.jpg",
                                            tags: ["tag1", "tag2"])
        
        // When
        let result = try await serviceRepository.create(request: request, on: db)
        
        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.number, 1)
        XCTAssertEqual(result.name, "Service")
        XCTAssertEqual(result.description!, "Service description")
        XCTAssertEqual(result.price, 100.0)
        XCTAssertEqual(result.unit, "unit")
        XCTAssertEqual(result.images.count, 2)
        XCTAssertEqual(result.coverImage, "cover.jpg")
        XCTAssertEqual(result.tags.count, 2)
        
        XCTAssertEqual(result.$category.id, category.id)
    }
    
    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        let request = ServiceRequest.Create(name: "Service",
                                            description: "Service description",
                                            price: 100.0,
                                            unit: "unit")
        
        // When
        do {
            _ = try await serviceRepository.create(request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testCreate_WithNonExistentCategoryId_ShouldThrowError() async throws {
        // Given
        let request = ServiceRequest.Create(name: "Service",
                                            description: "Service description",
                                            price: 100.0,
                                            unit: "unit",
                                            categoryId: UUID())
        
        // When
        do {
            _ = try await serviceRepository.create(request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }
    
    // MARK: - Update Tests

    func testUpdate_WithValidData_ShouldUpdateService() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        let request = ServiceRequest.Update(name: "Updated Service",
                                            description: "Updated description",
                                            price: 200.0,
                                            unit: "new unit",
                                            images: ["new_image1.jpg", "new_image2.jpg"],
                                            coverImage: "new_cover.jpg",
                                            tags: ["new_tag1", "new_tag2"])
        
        // When
        let result = try await serviceRepository.update(byId: .init(id: service.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.name, "Updated Service")
        XCTAssertEqual(result.description!, "Updated description")
        XCTAssertEqual(result.price, 200.0)
        XCTAssertEqual(result.unit, "new unit")
        XCTAssertEqual(result.images.count, 2)
        XCTAssertEqual(result.coverImage, "new_cover.jpg")
        XCTAssertEqual(result.tags.count, 2)
    }
    
    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit")
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        let request = ServiceRequest.Update(name: "Service2")
        
        // When
        do {
            _ = try await serviceRepository.update(byId: .init(id: service1.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? CommonError, .duplicateName)
        }
    }
    
    func testUpdate_WithNonExistentCategoryId_ShouldThrowError() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        let request = ServiceRequest.Update(categoryId: UUID())
        
        // When
        do {
            _ = try await serviceRepository.update(byId: .init(id: service.id!), request: request, on: db)
            XCTFail("Should throw error")
        } catch {
            // Then
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }
    
    func testUpdate_WithCategoryId_ShouldUpdateService() async throws {
        // Given
        let category1 = ServiceCategory(name: "Category1")
        let category2 = ServiceCategory(name: "Category2")
        try await category1.create(on: db)
        try await category2.create(on: db)
        
        let service = Service(number: 1, 
                              name: "Service",
                              description: "Desc",
                              price: 100.0,
                              unit: "unit",
                              categoryId: category1.id!)
        try await service.create(on: db)

        let request = ServiceRequest.Update(categoryId: category2.id)
        
        // When
        let result = try await serviceRepository.update(byId: .init(id: service.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.$category.id, category2.id)
    }
    
    // MARK: - Delete Tests

    func testDelete_ShouldMarkServiceAsDeleted() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        let result = try await serviceRepository.delete(byId: .init(id: service.id!), on: db)
        
        // Then
        XCTAssertNotNil(result.deletedAt)
    }
    
    // MARK: - Search Tests

    func testSearch_WithName_ShouldReturnService() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        let request = GeneralRequest.Search(query: "Service")
        
        // When
        let result = try await serviceRepository.search(request: request, on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "Service")
    }
    
    func testSearch_WithNumber_ShouldReturnService() async throws {
        // Given
        let service = Service(number: 123, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        let request = GeneralRequest.Search(query: "123")
        
        // When
        let result = try await serviceRepository.search(request: request, on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.number, 123)
    }
    
    // MARK: - Fetch Lasted Number Tests

    func testFetchLastedNumber_ShouldReturnLastNumber() async throws {
        // Given
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit")
        try await service.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 1)
    }
    
    func testFetchLastedNumber_WithDeleted_ShouldReturnLastNumber() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", deletedAt: .init())
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 2)
    }
    
    func testFetchLastedNumber_WithEmptyService_ShouldReturnZero() async throws {
        // When
        let result = try await serviceRepository.fetchLastedNumber(on: db)
        
        // Then
        XCTAssertEqual(result, 0)
    }
}

// MARK: - Stub Data

private extension ServiceRepositoryTests {
    struct Stub {
        static var group40: [Service] {
            (0..<40).map { Service(number: $0 + 1, 
                                   name: "Service\($0)",
                                   description: "Desc\($0)",
                                   price: 100.0,
                                   unit: "unit") }
        }
        
        static var serviceCategory: ServiceCategory {
            ServiceCategory(name: "Category")
        }
    }
}
