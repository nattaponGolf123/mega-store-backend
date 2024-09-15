//
//  ServiceControllerTests.swift
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

final class ServiceControllerTests: XCTestCase {

    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    var app: Application!
    var db: Database!
    
    //lazy var repo = MockServiceRepositoryProtocol()
    lazy var serviceCategoryRepo = ServiceCategoryRepository()
    lazy var repo = ServiceRepository(serviceCategoryRepository: serviceCategoryRepo)
    lazy var validator = MockServiceValidatorProtocol()
    
    var controller: ServiceController!
    
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
        
        // Register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
        
        //drop table
        try await dropCollection(db,
                                 schema: ServiceCategory.schema)
        try await dropCollection(db,
                                 schema: Service.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /services
    func testAll_WithNoRequestParam_ShouldReturnEmptyServices() async throws {
        
        // Given
        
        //given(repo).fetchAll(request: .any, on: .any).willReturn(Stub.emptyPageService)
        
        try app.test(.GET, "services") { res in
            XCTAssertEqual(res.status, .ok)
            let services = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
            XCTAssertEqual(services.items.count, 0)
        }
    }
    
    func testAll_WithValidRequest_ShouldReturnAllServices() async throws {
        
        // Given
        
        let category = ServiceCategory(name: "C1")
        try await category.save(on: db)
        
        let service1 = Service(number: 1,
                               name: "S1",
                               categoryId: category.id!)
        let service2 = Service(number: 2,
                                 name: "S2")
        try await service1.save(on: db)
        try await service2.save(on: db)
        //given(repo).fetchAll(request: .any, on: .any).willReturn(Stub.pageService)
    
        try app.test(.GET, "services") { res in
            XCTAssertEqual(res.status, .ok)
            let services = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
            XCTAssertEqual(services.items.count, 2)
        }
    }
    
    // MARK: - Test GET /services/:id
    func testGetByID_WithInvalidID_ShouldReturnNotFound() async throws {
        
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        
//        given(repo).fetchById(request: .matching({ $0.id == id }), on: .any).willThrow(DefaultError.notFound)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "services/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
        
    }
    
    func testGetByID_WithValidID_ShouldReturnService() async throws {
        
        let service = Service(number: 1,
                              name: "Yoga Class",
                              description: "Relaxing Yoga",
                              price: 20.0, 
                              unit: "hour",
                              images: [],
                              coverImage: nil,
                              tags: [])
        try await service.save(on: db)
        
        // Given
        let request = GeneralRequest.FetchById(id: service.id!)
        
        // Given
//        given(repo).fetchById(request: .any,
//                              on: .any).willReturn(Stub.service)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.GET, "services/\(service.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(ServiceResponse.self)
            XCTAssertEqual(service.name, "Yoga Class")
        }
    }
    
    // MARK: - Test POST /services
    func testCreate_WithInvalidService_ShouldReturnBadRequest() async throws {
        
        // Given
        let request = ServiceRequest.Create(name: "",
                                            description: nil,
                                            price: 0,
                                            unit: "",
                                            categoryId: nil,
                                            images: [],
                                            coverImage: nil,
                                            tags: [])
        given(validator).validateCreate(.any).willThrow(DefaultError.insertFailed)
                
//        given(repo).create(request: .matching({ $0.name == request.name }), on: .any).willThrow(DefaultError.insertFailed)
        
        try app.test(.POST, "services",
                     beforeRequest: { req in
                        try req.content.encode(request)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testCreate_WithValidService_ShouldReturnService() async throws {
        
        // Given
        let category = ServiceCategory(name: "C1")
        try await category.save(on: db)
        
        let request = ServiceRequest.Create(name: "S1",
                                            description: "D1",
                                            price: 10.0,
                                            unit: "hour",
                                            categoryId: category.id!,
                                            images: [],
                                            coverImage: nil,
                                            tags: [])
        given(validator).validateCreate(.any).willReturn(request)
        
        try app.test(.POST, "services",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(ServiceResponse.self)
            XCTAssertEqual(service.name, "S1")
        }
    }
    
    // MARK: - Test PUT /services/:id
    func testUpdate_WithInvalidService_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = ServiceRequest.Update(name: "")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        
        let repo = MockServiceRepositoryProtocol()
        controller = .init(repository: repo,
                           validator: validator)
        
        try app.register(collection: controller)

        given(repo).update(byId: .matching({ $0.id == id }), request: .matching({ $0.name == requestUpdate.name }), on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.PUT, "services/\(id.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUpdate_WithValidService_ShouldReturnService() async throws {
        
        let service = Service(number: 1,
                              name: "Yoga Class",
                              description: "Relaxing Yoga",
                              price: 20.0, 
                              unit: "hour",
                              images: [],
                              coverImage: nil,
                              tags: [])
        try await service.save(on: db)
        
        // Given
        let requestUpdate = ServiceRequest.Update(name: "Updated Yoga Class")
        let request = GeneralRequest.FetchById(id: service.id!)
        given(validator).validateUpdate(.any).willReturn((request, requestUpdate))
        
        try app.test(.PUT, "services/\(service.id!.uuidString)",
                     beforeRequest: { req in
                        try req.content.encode(requestUpdate)
                     }) { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(ServiceResponse.self)
            XCTAssertEqual(service.name, "Updated Yoga Class")
        }
    }
    
    // MARK: - Test DELETE /services/:id
    func testDelete_WithInvalidService_ShouldReturnBadRequest() async throws {
        
        // Given
        let id = UUID()
        let repo = MockServiceRepositoryProtocol()
        controller = .init(repository: repo,
                           validator: validator)
        
        try app.register(collection: controller)

        let request = GeneralRequest.FetchById(id: id)
        given(validator).validateID(.any).willReturn(request)
        given(repo).delete(byId: .any,
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.DELETE, "services/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testDelete_WithValidService_ShouldReturnService() async throws {
        
        let service = Service(number: 1,
                              name: "Yoga Class",
                              description: "Relaxing Yoga",
                              price: 20.0,
                              unit: "hour",
                              images: [],
                              coverImage: nil,
                              tags: [])
        try await service.save(on: db)
        
        // Given
        let request = GeneralRequest.FetchById(id: service.id!)
        given(validator).validateID(.any).willReturn(request)
        
        try app.test(.DELETE, "services/\(service.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
        }
                                                   
    }
    
    // MARK: - Test GET /services/search
    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
        // Given        
        let repo = MockServiceRepositoryProtocol()
        controller = .init(repository: repo,
                           validator: validator)
        
        try app.register(collection: controller)

        let request = GeneralRequest.Search(query: "123")
        given(validator).validateSearchQuery(.any).willReturn(request)
        given(repo).search(request: .any,
                           on: .any).willThrow(DefaultError.invalidInput)
        
        try app.test(.GET, "services/search") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testSearch_WithValidQuery_ShouldReturnServices() async throws {
        
        // Given
        let service1 = Service(number: 1,
                               name: "Yoga Class 1",
                               description: "Relaxing Yoga",
                               price: 20.0,
                               unit: "hour",
                               images: [],
                               coverImage: nil,
                               tags: [])
        
        let service2 = Service(number: 2,
                                 name: "Yoga Class 2",
                                 description: "Relaxing Yoga",
                                 price: 20.0,
                                 unit: "hour",
                                 images: [],
                                 coverImage: nil,
                                 tags: [])
        
        try await service1.save(on: db)
        try await service2.save(on: db)
        
        let query = Search(query: "1")
        given(validator).validateSearchQuery(.any).willReturn(query)
        
        try app.test(.GET, "services/search?query=1") { res in
            XCTAssertEqual(res.status, .ok)
            let services = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
            XCTAssertEqual(services.total, 1)
        }
    }

}

extension ServiceControllerTests {
    struct Stub {
        
        static var emptyPageService: PaginatedResponse<Service> {
            .init(page: 1, perPage: 10, total: 0, items: [])
        }
        
        static var pageService: PaginatedResponse<Service> {
            .init(page: 1,
                  perPage: 10,
                  total: 2,
                  items: [
                    Service(number: 1,
                            name: "Yoga Class",
                            description: "Relaxing Yoga",
                            price: 20.0,
                            unit: "hour",
                            images: [],
                            coverImage: nil,
                            tags: []),
                    Service(number: 2,
                            name: "Pilates Class",
                            description: "Core Strength",
                            price: 25.0,
                            unit: "hour",
                            //categoryId: ServiceCategory.IDValue(),
                            category: .init(name: "Yoga"),
                            images: [],
                            coverImage: nil,
                            tags: [])])
        }
        
        static var service: Service {
            .init(number: 1,
                  name: "Yoga Class",
                  description: "Relaxing Yoga",
                  price: 20.0, unit: "hour",
                  images: [],
                  coverImage: nil,
                  tags: [])
        }
    }
}
