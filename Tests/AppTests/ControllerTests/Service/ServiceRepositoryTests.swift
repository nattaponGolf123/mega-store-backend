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
    lazy var serviceCategoryRepository = MockServiceCategoryRepositoryProtocol()
    
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
        
        serviceRepository = ServiceRepository(serviceCategoryRepository: serviceCategoryRepository)
        
        try await dropCollection(db,
                                 schema: Service.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Fetch All Tests

    func testFetchAll_ShouldReturnAllServices() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit")
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", deletedAt: Date())
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
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithSortByGroupIdAsc_ShouldReturnServicesInAscendingOrderOfGroupId() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit", categoryId: UUID())
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", categoryId: UUID())
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .groupId, sortOrder: .asc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service1")
    }
    
    func testFetchAll_WithSortByGroupIdDesc_ShouldReturnServicesInDescendingOrderOfGroupId() async throws {
        // Given
        let service1 = Service(number: 1, name: "Service1", description: "Desc1", price: 100.0, unit: "unit", categoryId: UUID())
        let service2 = Service(number: 2, name: "Service2", description: "Desc2", price: 200.0, unit: "unit", categoryId: UUID())
        try await service1.create(on: db)
        try await service2.create(on: db)
        
        // When
        let result = try await serviceRepository.fetchAll(request: .init(sortBy: .groupId, sortOrder: .desc), on: db)
        
        // Then
        XCTAssertEqual(result.items.count, 2)
        XCTAssertEqual(result.items.first?.name, "Service2")
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
        given(serviceCategoryRepository).fetchById(request: .any,
                                                   on: .any).willReturn(category)
        
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
        XCTAssertEqual(result.categoryId, category.id)
        XCTAssertEqual(result.images.count, 2)
        XCTAssertEqual(result.coverImage, "cover.jpg")
        XCTAssertEqual(result.tags.count, 2)
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
        // Given                                       on: .any).willReturn(serviceCategory)
        given(serviceCategoryRepository).fetchById(request: .any,
                                                   on: .any).willThrow(DefaultError.notFound)
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
        given(serviceCategoryRepository).fetchById(request: .any,
                                                   on: .any).willThrow(DefaultError.notFound)
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
        
        let service = Service(number: 1, name: "Service", description: "Desc", price: 100.0, unit: "unit", categoryId: category1.id)
        try await service.create(on: db)
        
        given(serviceCategoryRepository).fetchById(request: .any,
                                                   on: .any).willReturn(category2)
        
        let request = ServiceRequest.Update(categoryId: category2.id)
        
        // When
        let result = try await serviceRepository.update(byId: .init(id: service.id!), request: request, on: db)
        
        // Then
        XCTAssertEqual(result.categoryId, category2.id)
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


//final class ServiceRepositoryTests: XCTestCase {
//    
//    var app: Application!
//    var db: Database!
//    
//    private(set) var contactRepository: ServiceRepository!
//    lazy var contactGroupRepository = MockServiceGroupRepositoryProtocol()
//    
//    // Database configuration
//    var dbHost: String!
//    
//    override func setUp() async throws {
//        try await super.setUp()
//        
//        app = Application(.testing)
//        dbHost = try dbHostURL(app)
//        
//        try configure(app,
//                      dbHost: dbHost,
//                      migration: ServiceMigration())
//        
//        db = app.db
//        
//        contactRepository = ServiceRepository(contactGroupRepository: contactGroupRepository)
//        
//        try await dropCollection(db,
//                                 schema: Service.schema)
//    }
//
//    override func tearDown() async throws {
//        
//        app.shutdown()
//        try await super.tearDown()
//    }
//    
//    //MARK: fetchAll
//    func testFetchAll_ShouldReturnAllService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2", deletedAt: Date())
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 1)
//        XCTAssertEqual(result.items.first?.name, "Service1")
//    }
//    
//    func testFetchAll_WithShowDeleted_ShouldDeletedService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2", deletedAt: Date())
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(showDeleted: true),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 2)
//    }
//    
//    //perPage min at 20
//    func testFetchAll_WithPagination_ShouldReturnService() async throws {
//        
//        // Given
//        let contacts = Stub.group40
//        await createGroups(groups: contacts,
//                           db: db)
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(page: 2,
//                                                                              perPage: 25),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 15)
//    }
//    
//    func testFetchAll_WithSortByNameDesc_ShouldReturnService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .desc),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 2)
//        XCTAssertEqual(result.items.first?.name, "Service2")
//    }
//    
//    func testFetchAll_WithSortByNameAsc_ShouldReturnService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(sortBy: .name, sortOrder: .asc),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 2)
//        XCTAssertEqual(result.items.first?.name, "Service1")
//    }
//    
//    func testFetchAll_WithSortByCreateAtDesc_ShouldReturnService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .desc),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 2)
//        XCTAssertEqual(result.items.first?.name, "Service1")
//    }
//    
//    func testFetchAll_WithSortByCreateAtAsc_ShouldReturnService() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchAll(request: .init(sortBy: .createdAt, sortOrder: .asc),
//                                                               on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 2)
//        XCTAssertEqual(result.items.first?.name, "Service1")
//    }
// 
//    //MARK: fetchById
//    func testFetchById_ShouldReturnService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchById(request: .init(id: contact.id!),
//                                                                on: db)
//        
//        // Then
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result.name, "Service")
//    }
//    
//    //MARK: fetchByName
//    func testFindFirstByName_ShouldReturnService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchByName(request: .init(name: "Service"),
//                                                                  on: db)
//        
//        // Then
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result.name, "Service")
//    }
//    
//    func testFindFirstByName_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let group = Service(name: "Service")
//        try await group.create(on: db)
//        
//        // When
//        do {
//            _ = try await contactRepository.fetchByName(request: .init(name: "Service1"),
//                                                                 on: db)
//            XCTFail("Should throw error")
//        } catch {
//            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
//        }
//    }
//    
//    
//    //MARK: fetchByTaxNumber
//    func testFetchByTaxNumber_ShouldReturnService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service", taxNumber: "123456789")
//        try await contact.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchByTaxNumber(request: .init(taxNumber: "123456789"),
//                                                                       on: db)
//        
//        // Then
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result.taxNumber, "123456789")
//    }
//    
//    func testFetchByTaxNumber_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let group = Service(name: "Service", taxNumber: "123456789")
//        try await group.create(on: db)
//        
//        // When
//        do {
//            _ = try await contactRepository.fetchByTaxNumber(request: .init(taxNumber: "987654321"),
//                                                               on: db)
//            XCTFail()
//        } catch {
//            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
//        }
//    }
//    
//    //MARK: create
//    func testCreate_ShouldCreateService() async throws {
//        
//        // Given
//        let group1 = ServiceGroup(name: "Group 1")
//        given(contactGroupRepository).fetchById(request: .any,
//                                                on: .any).willReturn(group1)
//        
//        let request = ServiceRequest.Create(name: "Service",
//                                            vatRegistered: false,
//                                            legalStatus: .individual,
//                                            groupId: group1.id)
//        
//        // When
//        let result = try await contactRepository.create(request: request,
//                                                            on: db)
//        
//        // Then
//        XCTAssertNotNil(result.id)
//        XCTAssertEqual(result.number, 1)
//        XCTAssertEqual(result.name, "Service")
//        XCTAssertEqual(result.groupId, group1.id)
//        XCTAssertEqual(result.kind, .both)
//        XCTAssertEqual(result.vatRegistered, false)
//        XCTAssertNil(result.taxNumber)
//        XCTAssertEqual(result.legalStatus, .individual)
//        XCTAssertNil(result.website)
//        XCTAssertEqual(result.businessAddress.count, 1)
//        XCTAssertEqual(result.shippingAddress.count, 1)
//        XCTAssertEqual(result.paymentTermsDays, 30)
//        XCTAssertNil(result.note)
//        XCTAssertNotNil(result.createdAt)
//        XCTAssertNotNil(result.updatedAt)
//        XCTAssertNil(result.deletedAt)
//    }
//    
//    func testCreate_WithDuplicateName_ShouldThrowError() async throws {
//        
//        // Given
//        let contact = Service(name: "Service",
//                            vatRegistered: false,
//                            legalStatus: .individual)
//        try await contact.create(on: db)
//        
//        let request = ServiceRequest.Create(name: "Service",
//                                            vatRegistered: false,
//                                            legalStatus: .individual)
//        
//        // When
//        do {
//            _ = try await contactRepository.create(request: request,
//                                                        on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? CommonError, .duplicateName)
//        }
//    }
//    
//    func testCreate_WithDuplicateTaxNumber_ShouldThrowError() async throws {
//        
//        // Given
//        let contact = Service(name: "Service",
//                            vatRegistered: false,
//                            taxNumber: "123456789",
//                            legalStatus: .individual)
//        try await contact.create(on: db)
//        
//        let request = ServiceRequest.Create(name: "Service 2",
//                                            vatRegistered: false,
//                                            taxNumber: "123456789",
//                                            legalStatus: .individual)
//        
//        // When
//        do {
//            _ = try await contactRepository.create(request: request,
//                                                        on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? CommonError, .duplicateTaxNumber)
//        }
//    }
//    
//    func testCreate_WithNotExistGroupID_ShouldThrowError() async throws {
//        
//        // Given
//        given(contactGroupRepository).fetchById(request: .any,
//                                                on: .any).willThrow(DefaultError.notFound)
//        
//        let request = ServiceRequest.Create(name: "Service",
//                                            vatRegistered: false,
//                                            legalStatus: .individual,
//                                            groupId: UUID())
//        
//        // When
//        do {
//            _ = try await contactRepository.create(request: request,
//                                                        on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
//        }
//    }
//    
//    func testCreate_WithVatRegistered_ShouldCreateService() async throws {
//        
//        // Given
//        let request = ServiceRequest.Create(name: "Service",
//                                            vatRegistered: true,
//                                            legalStatus: .individual)
//        
//        // When
//        let result = try await contactRepository.create(request: request,
//                                                            on: db)
//        
//        // Then
//        XCTAssertNotNil(result.id)
//        XCTAssertEqual(result.number, 1)
//        XCTAssertEqual(result.name, "Service")
//        XCTAssertNil(result.groupId)
//        XCTAssertEqual(result.kind, .both)
//        XCTAssertEqual(result.vatRegistered, true)
//        XCTAssertNil(result.taxNumber)
//        XCTAssertEqual(result.legalStatus, .individual)
//        XCTAssertNil(result.website)
//        XCTAssertEqual(result.businessAddress.count, 1)
//        XCTAssertEqual(result.shippingAddress.count, 1)
//        XCTAssertEqual(result.paymentTermsDays, 30)
//        XCTAssertNil(result.note)
//        XCTAssertNotNil(result.createdAt)
//        XCTAssertNotNil(result.updatedAt)
//        XCTAssertNil(result.deletedAt)
//    }
//    
//    //MARK: update
//    
//    func testUpdate_WithName_ShouldUpdateService() async throws {
//        
//        // Given
//        let group = Service(name: "Service")
//        try await group.create(on: db)
//                
//        let request = ServiceRequest.Update(name: "Service2",
//                                             vatRegistered: false,
//                                             contactInformation: .init(contactPerson: "Service Person",
//                                                                       phone: "1234567890",
//                                                                       email: "abc@email.com"),
//                                             taxNumber: "123456788",
//                                             legalStatus: .individual,
//                                             website: "Website",
//                                             note: "Note",
//                                             paymentTermsDays: 28)
//        
//        let fetchById = GeneralRequest.FetchById(id: group.id!)
//        
//        // When
//        let result = try await contactRepository.update(byId: fetchById,
//                                                        request: request,
//                                                        on: db)
//        // Then
//        XCTAssertEqual(result.name, "Service2")
//    }
//    
//    func testUpdate_WithExistGroupId_ShouldUpdateService() async throws {
//        
//        // Given
//        let group = ServiceGroup(name: "Group 2")
//        given(contactGroupRepository).fetchById(request: .any,
//                                                on: .any).willReturn(group)
//        
//        let contact = Service(name: "Service",
//                            groupId: nil)
//        try await contact.create(on: db)
//        
//        let request = ServiceRequest.Update(name: "Service 3",
//                                            vatRegistered: false,
//                                            groupId: group.id)
//        
//        let fetchById = GeneralRequest.FetchById(id: contact.id!)
//        
//        // When
//        let result = try await contactRepository.update(byId: fetchById,
//                                                        request: request,
//                                                        on: db)
//        
//        // Then
//        XCTAssertEqual(result.groupId, group.id)
//    }
//    
//    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1")
//        let contact2 = Service(name: "Service2")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        let request = ServiceRequest.Update(name: "Service2")
//        
//        let fetchById = GeneralRequest.FetchById(id: contact1.id!)
//        
//        // When
//        do {
//            _ = try await contactRepository.update(byId: fetchById,
//                                                   request: request,
//                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? CommonError, .duplicateName)
//        }
//    }
//    
//    func testUpdate_WithDuplicateTaxNumber_ShouldThrowError() async throws {
//        
//        // Given
//        let contact1 = Service(name: "Service1",
//                             vatRegistered: false,
//                             taxNumber: "123456789")
//        let contact2 = Service(name: "Service2",
//                             vatRegistered: false,
//                             taxNumber: "123456788")
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        
//        let request = ServiceRequest.Update(name: "Service3",
//                                            vatRegistered: false,
//                                            taxNumber: "123456788")
//        
//        let fetchById = GeneralRequest.FetchById(id: contact1.id!)
//        
//        // When
//        do {
//            _ = try await contactRepository.update(byId: fetchById,
//                                                   request: request,
//                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? CommonError, .duplicateTaxNumber)
//        }
//    }
//    
//    func testUpdate_WithNotExistGroupId_ShouldThrowError() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        given(contactGroupRepository).fetchById(request: .any,
//                                                on: .any).willThrow(DefaultError.notFound)
//        
//        let request = ServiceRequest.Update(name: "Service2",
//                                            vatRegistered: false,
//                                            legalStatus: .individual,
//                                            groupId: UUID())
//        
//        let fetchById = GeneralRequest.FetchById(id: contact.id!)
//        
//        // When
//        do {
//            _ = try await contactRepository.update(byId: fetchById,
//                                                   request: request,
//                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//    
//    func testUpdate_WithNotFoundId_ShouldThrowError() async throws {
//        
//        // Given
//        let request = ServiceRequest.Update(name: "Service2")
//        
//        let fetchById = GeneralRequest.FetchById(id: UUID())
//        
//        // When
//        do {
//            _ = try await contactRepository.update(byId: fetchById,
//                                                   request: request,
//                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//    
//    //MARK: updateBussineseAddress
//
//    func testUpdateBusinessAddress_WithExistAddressAndValidInfo_ShouldUpdateService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let address = contact.businessAddress.first!
//                
//        let requestId = GeneralRequest.FetchById(id: contact.id!)
//        let requestAddressId = GeneralRequest.FetchById(id: address.id)
//        let request = ServiceRequest.UpdateBussineseAddress(address: "928/12",
//                                                            branch: "Head Office",
//                                                            branchCode: "00000",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839",
//                                                            email: "abc@email.com",
//                                                            fax: "0293848839")        
//        
//        // When
//        let result = try await contactRepository.updateBussineseAddress(byId: requestId,
//                                                                        addressID: requestAddressId,
//                                                                        request: request,
//                                                                        on: db)
//        
//        // Then
//        XCTAssertEqual(result.businessAddress.count, 1)
//        XCTAssertEqual(result.businessAddress.first?.address, "928/12")
//        XCTAssertEqual(result.businessAddress.first?.branch, "Head Office")
//        XCTAssertEqual(result.businessAddress.first?.branchCode, "00000")
//        XCTAssertEqual(result.businessAddress.first?.subDistrict, "Bank Chak")
//        XCTAssertEqual(result.businessAddress.first?.city, "Prakanong")
//        XCTAssertEqual(result.businessAddress.first?.province, "Bangkok")
//        XCTAssertEqual(result.businessAddress.first?.country, "Thailand")
//        XCTAssertEqual(result.businessAddress.first?.postalCode, "12345")
//        XCTAssertEqual(result.businessAddress.first?.phone, "0293848839")
//        XCTAssertEqual(result.businessAddress.first?.email, "abc@email.com")
//        XCTAssertEqual(result.businessAddress.first?.fax, "0293848839")
//        
//    }
//    
//    func testUpdateBusinessAddress_WithNotServiceId_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let address = contact.businessAddress.first!
//        
//        let requestId = GeneralRequest.FetchById(id: UUID())
//        let requestAddressId = GeneralRequest.FetchById(id: address.id)
//        let request = ServiceRequest.UpdateBussineseAddress(address: "928/12",
//                                                            branch: "Head Office",
//                                                            branchCode: "00000",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839",
//                                                            email: "",
//                                                            fax: "")
//        
//        // When
//        do {
//            _ = try await contactRepository.updateBussineseAddress(byId: requestId,
//                                                                   addressID: requestAddressId,
//                                                                   request: request,
//                                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//    
//    func testUpdateBusinessAddress_WithNotExistAddressId_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let requestId = GeneralRequest.FetchById(id: contact.id!)
//        let requestAddressId = GeneralRequest.FetchById(id: UUID())
//        let request = ServiceRequest.UpdateBussineseAddress(address: "928/12",
//                                                            branch: "Head Office",
//                                                            branchCode: "00000",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839",
//                                                            email: "", 
//                                                            fax: "")
//        
//        // When
//        do {
//            _ = try await contactRepository.updateBussineseAddress(byId: requestId,
//                                                                   addressID: requestAddressId,
//                                                                   request: request,
//                                                                   on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//    
//    //MARK: updateShippingAddress
//    func testUpdateShippingAddress_ShouldUpdateShippingAddress() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let address = contact.shippingAddress.first!
//        
//        let requestId = GeneralRequest.FetchById(id: contact.id!)
//        let requestAddressId = GeneralRequest.FetchById(id: address.id)
//        let request = ServiceRequest.UpdateShippingAddress(address: "928/12",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839")
//        
//        // When
//        let result = try await contactRepository.updateShippingAddress(byId: requestId,
//                                                                       addressID: requestAddressId,
//                                                                       request: request,
//                                                                       on: db)
//        
//        // Then
//        XCTAssertEqual(result.shippingAddress.count, 1)
//        XCTAssertEqual(result.shippingAddress.first?.address, "928/12")
//        XCTAssertEqual(result.shippingAddress.first?.subDistrict, "Bank Chak")
//        XCTAssertEqual(result.shippingAddress.first?.city, "Prakanong")
//        XCTAssertEqual(result.shippingAddress.first?.province, "Bangkok")
//        XCTAssertEqual(result.shippingAddress.first?.country, "Thailand")
//        XCTAssertEqual(result.shippingAddress.first?.postalCode, "12345")
//        XCTAssertEqual(result.shippingAddress.first?.phone, "0293848839")
//    }
//    
//    func testUpdateShippingAddress_WithNotServiceId_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let address = contact.shippingAddress.first!
//        
//        let requestId = GeneralRequest.FetchById(id: UUID())
//        let requestAddressId = GeneralRequest.FetchById(id: address.id)
//        let request = ServiceRequest.UpdateShippingAddress(address: "928/12",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839")
//        
//        // When
//        do {
//            _ = try await contactRepository.updateShippingAddress(byId: requestId,
//                                                                  addressID: requestAddressId,
//                                                                  request: request,
//                                                                  on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//    
//    func testUpdateShippingAddress_WithNotExistAddressId_ShouldThrowNotFound() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let requestId = GeneralRequest.FetchById(id: contact.id!)
//        let requestAddressId = GeneralRequest.FetchById(id: UUID())
//        let request = ServiceRequest.UpdateShippingAddress(address: "928/12",
//                                                            subDistrict: "Bank Chak",
//                                                            city: "Prakanong",
//                                                            province: "Bangkok",
//                                                            country: "Thailand",
//                                                            postalCode: "12345",
//                                                            phone: "0293848839")
//        
//        // When
//        do {
//            _ = try await contactRepository.updateShippingAddress(byId: requestId,
//                                                                  addressID: requestAddressId,
//                                                                  request: request,
//                                                                  on: db)
//            XCTFail("Should throw error")
//        } catch {
//            // Then
//            XCTAssertEqual(error as? DefaultError, .notFound)
//        }
//    }
//        
//    
//    //MARK: delete
//    func testDelete_ShouldDeleteService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service",
//                            vatRegistered: false,
//                            legalStatus: .individual)
//        try await contact.create(on: db)
//        
//        let fetchById = GeneralRequest.FetchById(id: contact.id!)
//        
//        // When
//        let result = try await contactRepository.delete(byId: fetchById,
//                                                            on: db)
//        
//        // Then
//        XCTAssertNotNil(result.deletedAt)
//    }
//    
//    //MARK: search
//    func testSearch_WithName_ShouldReturnService() async throws {
//        
//        // Given
//        let contact = Service(name: "Service")
//        try await contact.create(on: db)
//        
//        let request = GeneralRequest.Search(query: "Service")
//        
//        // When
//        let result = try await contactRepository.search(request: request,
//                                                        on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 1)
//        XCTAssertEqual(result.items.first?.name, "Service")
//    }
//    
//    func testSearch_WithNumber_ShouldReturnService() async throws {
//        
//        // Given
//        let contact = Service(number: 123)
//        try await contact.create(on: db)
//        
//        let request = GeneralRequest.Search(query: "123")
//        
//        // When
//        let result = try await contactRepository.search(request: request,
//                                                        on: db)
//        
//        // Then
//        XCTAssertEqual(result.items.count, 1)
//        XCTAssertEqual(result.items.first?.number, 123)
//    }
//    
//    //MARK: test fetchLastedNumber
//    func testFetchLastedNumber_ShouldReturnNumber() async throws {
//        
//        // Given
//        let contact = Service(number: 1, 
//                              name: "Service")
//        try await contact.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchLastedNumber(on: db)
//        
//        // Then
//        XCTAssertEqual(result, 1)
//    }
//    
//    func testFetchLastedNumber_WithDeleted_ShouldReturnNumber() async throws {
//        
//        // Given
//        let contact1 = Service(number: 1,
//                               name: "Service")
//        let contact2 = Service(number: 2,
//                               name: "Service 2",
//                               deletedAt: .init())
//        
//        try await contact1.create(on: db)
//        try await contact2.create(on: db)
//        
//        // When
//        let result = try await contactRepository.fetchLastedNumber(on: db)
//        
//        // Then
//        XCTAssertEqual(result, 2)
//    }
//    
//    func testFetchLastedNumber_WithEmptyService_ShouldReturn1() async throws {
//        
//        // When
//        let result = try await contactRepository.fetchLastedNumber(on: db)
//        
//        // Then
//        XCTAssertEqual(result, 0)
//    }
//}
//
//private extension ServiceRepositoryTests {
//    struct Stub {
//        static var group40: [Service] {
//            (0..<40).map { Service(name: "Service\($0)") }
//        }
//    }
//}

/*
 import Foundation
 import Vapor
 import Fluent
 import FluentMongoDriver

 protocol ServiceRepositoryProtocol {
 //    func fetchAll(req: GeneralRequest.FetchAll,
 //                  on db: Database) async throws -> PaginatedResponse<ServiceResponse>
 //    func create(content: ServiceRequest.Create, on db: Database) async throws -> ServiceResponse
 //    func find(id: UUID, on db: Database) async throws -> ServiceResponse
 //    func find(name: String, on db: Database) async throws -> ServiceResponse
 //    func update(id: UUID, with content: ServiceRequest.Update, on db: Database) async throws -> ServiceResponse
 //    func delete(id: UUID, on db: Database) async throws -> ServiceResponse
 //    func search(req: GeneralRequest.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse>
 //    func fetchLastedNumber(on db: Database) async throws -> Int
 //
     // new
     typealias FetchAll = GeneralRequest.FetchAll
     typealias Search = GeneralRequest.Search
     
     func fetchAll(
         request: FetchAll,
         on db: Database
     ) async throws -> PaginatedResponse<Service>
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Service
     
     func fetchByName(
         request: GeneralRequest.FetchByName,
         on db: Database
     ) async throws -> Service
     
     func create(
         request: ServiceRequest.Create,
         on db: Database
     ) async throws -> Service
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ServiceRequest.Update,
         on db: Database
     ) async throws -> Service
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Service
     
     func search(
         request: Search,
         on db: Database
     ) async throws -> PaginatedResponse<Service>
     
     func fetchLastedNumber(
         on db: Database
     ) async throws -> Int
 }


 class ServiceRepository: ServiceRepositoryProtocol {
     
     typealias FetchAll = GeneralRequest.FetchAll
     typealias Search = GeneralRequest.Search
     
     private var serviceCategoryRepository: ServiceCategoryRepositoryProtocol
     
     init(serviceCategoryRepository: ServiceCategoryRepositoryProtocol = ServiceCategoryRepository()) {
         self.serviceCategoryRepository = serviceCategoryRepository
     }
     
     func fetchAll(
         request: FetchAll,
         on db: any Database
     ) async throws -> PaginatedResponse<Service> {
         
         let query = Service.query(on: db)
         
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
     
     func fetchById(
         request: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Service {
         guard
             let found = try await Service.query(on: db).filter(\.$id == request.id).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func fetchByName(
         request: GeneralRequest.FetchByName,
         on db: Database
     ) async throws -> Service {
         guard
             let found = try await Service.query(on: db).filter(\.$name == request.name).first()
         else {
             throw DefaultError.notFound
         }
         
         return found
     }
     
     func create(
         request: ServiceRequest.Create,
         on db: Database
     ) async throws -> Service {
         // prevent duplicate name
         if let _ = try? await fetchByName(request: .init(name: request.name),
                                           on: db) {
             throw CommonError.duplicateName
         }
         
         if let groupId = request.categoryId {
             guard
                 let _ = try? await serviceCategoryRepository.fetchById(request: .init(id: groupId),
                                                                                  on: db)
             else { throw DefaultError.notFound }
         }
         
         let lastedNumber = try await fetchLastedNumber(on: db)
         let nextNumber = lastedNumber + 1
         
         let service = Service(number: nextNumber,
                                name: request.name,
                                description: request.description,
                                price: request.price,
                                unit: request.unit,
                                categoryId: request.categoryId,
                                images: request.images,
                                coverImage: request.coverImage,
                                tags: request.tags)
         
         try await service.save(on: db)
         return service
     }
     
     func update(
         byId: GeneralRequest.FetchById,
         request: ServiceRequest.Update,
         on db: Database
     ) async throws -> Service {
         var service = try await fetchById(request: .init(id: byId.id), on: db)
         
         if let name = request.name {
             // prevent duplicate name
             if let _ = try? await fetchByName(request: .init(name: name),
                                               on: db) {
                 throw CommonError.duplicateName
             }
             
             service.name = name
         }
         
         if let categoryId = request.categoryId {
             // try to fetch category id to check is exist
             guard
                 let _ = try? await serviceCategoryRepository.fetchById(request: .init(id: categoryId),
                                                                    on: db)
             else { throw DefaultError.notFound }
             
             service.categoryId = categoryId
         }
         
         if let description = request.description {
             service.description = description
         }
         
         if let price = request.price {
             service.price = price
         }
         
         if let unit = request.unit {
             service.unit = unit
         }
         
         if let images = request.images {
             service.images = images
         }
         
         if let coverImage = request.coverImage {
             service.coverImage = coverImage
         }
         
         if let tags = request.tags {
             service.tags = tags
         }
         
         try await service.save(on: db)
         return service
     }
     
     func delete(
         byId: GeneralRequest.FetchById,
         on db: Database
     ) async throws -> Service {
         let group = try await fetchById(request: .init(id: byId.id),
                                         on: db)
         try await group.delete(on: db)
         return group
     }
     
     func search(
         request: GeneralRequest.Search,
                 on db: Database
     ) async throws -> PaginatedResponse<Service> {
         
         let q = request.query
         let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
         let query = Service.query(on: db).group(.or) { or in
             or.filter(\.$name =~ regexPattern)
             if let number = Int(q) {
                 or.filter(\.$number == number)
             }
             or.filter(\.$description =~ regexPattern)
             
             //contain on tags string
             //or.filter(\.$tags, .custom("ILIKE"), regexPattern)
         }
         
         let total = try await query.count()
         let items = try await sortQuery(query: query,
                                         sortBy: request.sortBy,
                                         sortOrder: request.sortOrder,
                                         page: request.page,
                                         perPage: request.perPage)
         let responseItems = items.map { $0 }
         
         let response = PaginatedResponse(page: request.page,
                                          perPage: request.perPage,
                                          total: total,
                                          items: responseItems)
         return response
     }
     
     func fetchLastedNumber(
         on db: Database
     ) async throws -> Int {
         let query = Service.query(on: db).withDeleted()
         query.sort(\.$number, .descending)
         query.limit(1)
         
         let model = try await query.first()
         
         return model?.number ?? 0
     }
     
 }

 //    enum SortBy: String, Codable {
 //        case name
 //        case number
 //        case price
 //        case categoryId = "category_id"
 //        case createdAt = "created_at"
 //    }
 //
 private extension ServiceRepository {
     func sortQuery(query: QueryBuilder<Service>,
                    sortBy: SortBy,
                    sortOrder: SortOrder,
                    page: Int,
                    perPage: Int) async throws -> [Service] {
         let pageIndex = (page - 1)
         let pageStart = pageIndex * perPage
         let pageEnd = pageStart + perPage
         
         let range = pageStart..<pageEnd
         
         switch sortBy {
         case .name:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$name).range(range).all()
             case .desc:
                 return try await query.sort(\.$name, .descending).range(range).all()
             }
         case .createdAt:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$createdAt).range(range).all()
             case .desc:
                 return try await query.sort(\.$createdAt, .descending).range(range).all()
             }
         case .groupId:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$categoryId).range(range).all()
             case .desc:
                 return try await query.sort(\.$categoryId, .descending).range(range).all()
             }
         case .number:
             switch sortOrder {
             case .asc:
                 return try await query.sort(\.$number).range(range).all()
             case .desc:
                 return try await query.sort(\.$number, .descending).range(range).all()
             }
         default:
             return try await query.range(range).all()
         }
         
     }
 }

 /*
  //
  //  File.swift
  //
  //
  //  Created by IntrodexMac on 4/2/2567 BE.
  //

  import Foundation
  import Vapor
  import Fluent

  final class Service: Model, Content {
      static let schema = "Services"
      
      @ID(key: .id)
      var id: UUID?
      
      @Field(key: "number")
      var number: Int
      
      @Field(key: "name")
      var name: String
      
      @Field(key: "description")
      var description: String?
      
      @Field(key: "price")
      var price: Double
      
      @Field(key: "unit")
      var unit: String
      
      @Field(key: "category_id")
      var categoryId: UUID?
      
      @Field(key: "images")
      var images: [String]
      
      @Field(key: "cover_image")
      var coverImage: String?
      
      @Field(key: "tags")
      var tags: [String]
      
      @Timestamp(key: "created_at",
                 on: .create,
                 format: .iso8601)
      var createdAt: Date?
      
      @Timestamp(key: "updated_at",
                 on: .update,
                 format: .iso8601)
      var updatedAt: Date?
      
      @Timestamp(key: "deleted_at",
                 on: .delete,
                 format: .iso8601)
      var deletedAt: Date?
      
      init() { }
      
      init(id: UUID? = nil,
           number: Int,
           name: String,
           description: String?,
           price: Double = 0,
           unit: String = "",
           categoryId: UUID? = nil,
           images: [String] = [],
           coverImage: String? = nil,
           tags: [String] = [],
           createdAt: Date? = nil,
           updatedAt: Date? = nil,
           deletedAt: Date? = nil) {
          self.id = id ?? .init()
          self.number = number
          self.name = name
          self.description = description
          self.price = price
          self.unit = unit
          self.categoryId = categoryId
          self.images = images
          self.coverImage = coverImage
          self.tags = tags
          self.createdAt = createdAt ?? Date()
          self.updatedAt = updatedAt
          self.deletedAt = deletedAt
      }
      
  }

  extension Service {
      struct Stub {
          
          static var group: [Service] {
              [
                  self.yoga,
                  self.pilates,
                  self.spinning
              ]
          }
          
          static var yoga: Service {
              .init(number: 1,
                    name: "Yoga Class",
                    description: "A one-hour yoga class focusing on relaxation and flexibility.",
                    price: 20.00,
                    unit: "hour",
                    categoryId: nil,
                    images: [
                      "https://example.com/yoga-class-image1.jpg",
                      "https://example.com/yoga-class-image2.jpg"
                    ],
                    coverImage: nil,
                    tags: [])
          }
          
          static var pilates: Service {
              .init(number: 2,
                    name: "Pilates Class",
                    description: "A one-hour pilates class focusing on core strength and flexibility.",
                    price: 25.00,
                    unit: "hour",
                    categoryId: nil,
                    images: [
                      "https://example.com/pilates-class-image1.jpg",
                      "https://example.com/pilates-class-image2.jpg"
                    ])
          }
          
          static var spinning: Service {
              .init(number: 3,
                    name: "Spinning Class",
                    description: "A one-hour spinning class focusing on cardio and endurance.",
                    price: 15.00,
                    unit: "hour",
                    categoryId: .init(),
                    images: [
                      "https://example.com/spinning-class-image1.jpg",
                      "https://example.com/spinning-class-image2.jpg"
                    ])
          }
      }
  }

  */


 //class ServiceRepository: ServiceRepositoryProtocol {
 //
 //    func fetchAll(req: ServiceRepository.Fetch,
 //                  on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
 //        do {
 //            let page = req.page
 //            let perPage = req.perPage
 //            let sortBy = req.sortBy
 //            let sortOrder = req.sortOrder
 //
 //            guard page > 0, perPage > 0 else { throw DefaultError.invalidInput }
 //
 //            let query = Service.query(on: db)
 //
 //            if req.showDeleted {
 //                query.withDeleted()
 //            } else {
 //                query.filter(\.$deletedAt == nil)
 //            }
 //
 //            let total = try await query.count()
 //            let items = try await sortQuery(query: query,
 //                                            sortBy: sortBy,
 //                                            sortOrder: sortOrder,
 //                                            page: page,
 //                                            perPage: perPage)
 //
 //            let responseItems = items.map { ServiceResponse(from: $0) }
 //            let response = PaginatedResponse(page: page, perPage: perPage, total: total, items: responseItems)
 //
 //            return response
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func create(content: ServiceRepository.Create, on db: Database) async throws -> ServiceResponse {
 //        do {
 //            let lastedNumber = try await fetchLastedNumber(on: db)
 //            let nextNumber = lastedNumber + 1
 //            let newModel = Service(number: nextNumber,
 //                                   name: content.name,
 //                                   description: content.description,
 //                                   price: content.price,
 //                                   unit: content.unit,
 //                                   categoryId: content.categoryId,
 //                                   images: content.images,
 //                                   coverImage: content.coverImage,
 //                                   tags: content.tags)
 //
 //            try await newModel.save(on: db)
 //
 //            return ServiceResponse(from: newModel)
 //        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
 //            throw CommonError.duplicateName
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func find(id: UUID, on db: Database) async throws -> ServiceResponse {
 //        do {
 //            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
 //
 //            return ServiceResponse(from: model)
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func find(name: String, on db: Database) async throws -> ServiceResponse {
 //        do {
 //            guard let model = try await Service.query(on: db).filter(\.$name == name).first() else { throw DefaultError.notFound }
 //
 //            return ServiceResponse(from: model)
 //        } catch let error as DefaultError {
 //            throw error
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func update(id: UUID, with content: ServiceRepository.Update, on db: Database) async throws -> ServiceResponse {
 //        do {
 //            let updateBuilder = Self.updateFieldsBuilder(uuid: id, content: content, db: db)
 //            try await updateBuilder.update()
 //
 //            guard let model = try await Self.getByIDBuilder(uuid: id, db: db).first() else { throw DefaultError.notFound }
 //
 //            return ServiceResponse(from: model)
 //        } catch let error as FluentMongoDriver.FluentMongoError where error == .insertFailed {
 //            throw CommonError.duplicateName
 //        } catch let error as DefaultError {
 //            throw error
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func delete(id: UUID, on db: Database) async throws -> ServiceResponse {
 //        do {
 //            guard let model = try await Service.query(on: db).filter(\.$id == id).first() else { throw DefaultError.notFound }
 //
 //            try await model.delete(on: db).get()
 //
 //            return ServiceResponse(from: model)
 //        } catch let error as DefaultError {
 //            throw error
 //        } catch {
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func search(req: ServiceRepository.Search, on db: Database) async throws -> PaginatedResponse<ServiceResponse> {
 //        do {
 //            let perPage = req.perPage
 //            let page = req.page
 //            let keyword = req.q
 //            let sort = req.sortBy
 //            let order = req.sortOrder
 //
 //            guard
 //                keyword.count > 0,
 //                perPage > 0,
 //                page > 0
 //            else { throw DefaultError.invalidInput }
 //
 //            let regexPattern = "(?i)\(keyword)"  // (?i) makes the regex case-insensitive
 //            let query = Service.query(on: db).group(.or) { or in
 //                or.filter(\.$name =~ regexPattern)
 //                or.filter(\.$description =~ regexPattern)
 //                if let number = Int(keyword) {
 //                    or.filter(\.$number == number)
 //                }
 //             }
 //
 //            let total = try await query.count()
 //            let items = try await sortQuery(query: query,
 //                                            sortBy: sort,
 //                                            sortOrder: order,
 //                                            page: page,
 //                                            perPage: perPage)
 //            let responseItems = items.map { ServiceResponse(from: $0) }
 //            let response = PaginatedResponse(page: page,
 //                                             perPage: perPage,
 //                                             total: total,
 //                                             items: responseItems)
 //
 //            return response
 //        } catch {
 //            // Handle all other errors
 //            throw DefaultError.error(message: error.localizedDescription)
 //        }
 //    }
 //
 //    func fetchLastedNumber(on db: Database) async throws -> Int {
 //        let query = Service.query(on: db).withDeleted()
 //        query.sort(\.$number, .descending)
 //        query.limit(1)
 //
 //        let model = try await query.first()
 //
 //        return model?.number ?? 0
 //    }
 //}
 //
 //
 //private extension ServiceRepository {
 //    func sortQuery(query: QueryBuilder<Service>,
 //                   sortBy: ServiceRepository.SortBy,
 //                   sortOrder: ServiceRepository.SortOrder,
 //                   page: Int,
 //                   perPage: Int) async throws -> [Service] {
 //        switch sortBy {
 //        case .name:
 //            switch sortOrder {
 //            case .asc:
 //                return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
 //            case .desc:
 //                return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
 //            }
 //        case .createdAt:
 //            switch sortOrder {
 //            case .asc:
 //                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
 //            case .desc:
 //                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
 //            }
 //        case .number:
 //            switch sortOrder {
 //            case .asc:
 //                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
 //            case .desc:
 //                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
 //            }
 //        case .price:
 //            switch sortOrder {
 //            case .asc:
 //                return try await query.sort(\.$price).range((page - 1) * perPage..<(page * perPage)).all()
 //            case .desc:
 //                return try await query.sort(\.$price, .descending).range((page - 1) * perPage..<(page * perPage)).all()
 //            }
 //        case .categoryId:
 //            switch sortOrder {
 //            case .asc:
 //                return try await query.sort(\.$categoryId).range((page - 1) * perPage..<(page * perPage)).all()
 //            case .desc:
 //                return try await query.sort(\.$categoryId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
 //            }
 //        }
 //    }
 //}
 //
 //extension ServiceRepository {
 //
 //    static func updateFieldsBuilder(uuid: UUID, content: ServiceRepository.Update, db: Database) -> QueryBuilder<Service> {
 //        let updateBuilder = Service.query(on: db).filter(\.$id == uuid)
 //
 //        if let name = content.name {
 //            updateBuilder.set(\.$name, to: name)
 //        }
 //
 //        if let description = content.description {
 //            updateBuilder.set(\.$description, to: description)
 //        }
 //
 //        if let price = content.price {
 //            updateBuilder.set(\.$price, to: price)
 //        }
 //
 //        if let unit = content.unit {
 //            updateBuilder.set(\.$unit, to: unit)
 //        }
 //
 //        if let categoryId = content.categoryId {
 //            updateBuilder.set(\.$categoryId, to: categoryId)
 //        }
 //
 //        if let images = content.images {
 //            updateBuilder.set(\.$images, to: images)
 //        }
 //
 //        if let coverImage = content.coverImage {
 //            updateBuilder.set(\.$coverImage, to: coverImage)
 //        }
 //
 //        if let tags = content.tags {
 //            updateBuilder.set(\.$tags, to: tags)
 //        }
 //
 //        return updateBuilder
 //    }
 //
 //    static func getByIDBuilder(uuid: UUID, db: Database) -> QueryBuilder<Service> {
 //        return Service.query(on: db).filter(\.$id == uuid)
 //    }
 //}
 //

 */
