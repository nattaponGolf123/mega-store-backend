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
//
//final class ServiceControllerTests: XCTestCase {
//    
//    var app: Application!
//    var db: Database!
//    
//    lazy var repo = MockServiceRepositoryProtocol()
//    lazy var validator = MockServiceValidatorProtocol()
//    
//    var controller: ServiceController!
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
//        try await dropCollection(db,
//                                 schema: Service.schema)
//        
//        //register service controller
//        controller = .init(repository: repo,
//                           validator: validator)
//        try app.register(collection: controller)
//    }
//    
//    override func tearDown() async throws {
//        
//        app.shutdown()
//        try await super.tearDown()
//    }
//    
//    // MARK: - Tests GET /contacts
//    func testAll_WithNoRequestParam_ShouldReturnEmptyServices() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .any,
//                             on: .any).willReturn(Stub.emptyService)
//        
//        try app.test(.GET, "contacts") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
//            XCTAssertEqual(groups.items.count, 0)
//        }
//    }
//    
//    func testAll_WithNoRequestParam_ShouldReturnAllServices() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .any,
//                             on: .any).willReturn(Stub.pageService)
//        
//        try app.test(.GET, "contacts") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
//            XCTAssertEqual(groups.items.count, 2)
//        }
//    }
//    
//    func testAll_WithShowDeleted_ShouldReturnAllServices() async throws {
//        
//        // Given
//        given(repo).fetchAll(request: .matching({ $0.showDeleted == true}),
//                             on: .any).willReturn(Stub.pageServiceWithDeleted)
//        
//        try app.test(.GET, "contacts?show_deleted=true") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
//            XCTAssertEqual(groups.items.count, 3)
//        }
//    }
//    
//    // MARK: - Test GET /contacts/:id
//    func testGetByID_WithID_ShouldReturnNotFound() async throws {
//        
//        // Given
//        let id = UUID()
//        let request = GeneralRequest.FetchById(id: id)
//        given(repo).fetchById(request: .matching({ $0.id == id}),
//                              on: .any).willThrow(DefaultError.notFound)
//        given(validator).validateID(.any).willReturn(request)
//        
//        try app.test(.GET, "contacts/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .notFound)
//        }
//        
//    }
//    
//    func testGetByID_WithMatchID_ShouldReturnService() async throws {
//        
//        // Given
//        let id = UUID()
//        let request = GeneralRequest.FetchById(id: id)
//        given(repo).fetchById(request: .matching({ $0.id == id}),
//                              on: .any).willReturn(Stub.contact)
//        given(validator).validateID(.any).willReturn(request)
//        
//        try app.test(.GET, "contacts/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    // MARK: - Test POST /contacts
//    func testCreate_WithEmptyServiceName_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let request = ServiceRequest.Create(name: "",
//                                            vatRegistered: false,
//                                            legalStatus: .individual)
//        given(validator).validateCreate(.any).willReturn(request)
//        
//        given(repo).create(request: .matching({ $0.name == request.name }),
//                           on: .any).willThrow(DefaultError.insertFailed)
//        
//        try app.test(.POST, "contacts",
//                     beforeRequest: { req in
//            try req.content.encode(request)
//        }) { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testCreate_WithValidName_ShouldReturnService() async throws {
//        
//        // Given
//        let request = ServiceRequest.Create(name: "Test",
//                                            vatRegistered: false,
//                                            legalStatus: .individual)
//        given(validator).validateCreate(.any).willReturn(request)
//        
//        given(repo).create(request: .matching({ $0.name == request.name }),
//                           on: .any).willReturn(Stub.contact)
//        
//        try app.test(.POST, "contacts",
//                     beforeRequest: { req in
//            try req.content.encode(request)
//        }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    func testCreate_WithValidInfo_ShouldReturnService() async throws {
//        
//        // Given
//        let request = ServiceRequest.Create(name: "Test",
//                                            vatRegistered: false,
//                                            contactInformation: .init(contactPerson: "John",
//                                                                      phone: "0123456789",
//                                                                      email: "ab@email.com"),
//                                            taxNumber: "123456",
//                                            legalStatus: .companyLimited,
//                                            website: "website",
//                                            note: "note",
//                                            groupId: nil,
//                                            paymentTermsDays: 30)
//        given(validator).validateCreate(.any).willReturn(request)
//        
//        let stub = Service(id: .init(),
//                           name: request.name,
//                           groupId: request.groupId,
//                           vatRegistered: request.vatRegistered,
//                           contactInformation: request.contactInformation!,
//                           taxNumber: request.taxNumber,
//                           legalStatus: request.legalStatus,
//                           website: request.website,
//                           paymentTermsDays: request.paymentTermsDays!,
//                           note: request.note,
//                           createAt: .now,
//                           updatedAt: .now)
//        given(repo).create(request: .matching({
//            $0.name == request.name &&
//            $0.taxNumber == request.taxNumber &&
//            $0.legalStatus == request.legalStatus &&
//            $0.paymentTermsDays == request.paymentTermsDays &&
//            $0.contactInformation == request.contactInformation &&
//            $0.website == request.website &&
//            $0.note == request.note &&
//            $0.groupId == request.groupId &&
//            $0.vatRegistered == request.vatRegistered
//        }),on: .any).willReturn(stub)
//        
//        try app.test(.POST, "contacts",
//                     beforeRequest: { req in
//            try req.content.encode(request)
//        }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let contact = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(contact.name, "Test")
//            XCTAssertEqual(contact.code, "C00001")
//            XCTAssertEqual(contact.taxNumber, "123456")
//            XCTAssertEqual(contact.legalStatus, .companyLimited)
//            XCTAssertEqual(contact.paymentTermsDays, 30)
//            XCTAssertEqual(contact.contactInformation, request.contactInformation)
//            XCTAssertEqual(contact.website, "website")
//            XCTAssertEqual(contact.note, "note")
//            XCTAssertNil(contact.groupId)
//            XCTAssertEqual(contact.vatRegistered, false)
//        }
//    }
//    
//    // MARK: - Test PUT /contacts/:id
//    func testUpdate_WithInvalidService_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        let requestId = GeneralRequest.FetchById(id: id)
//        let requestUpdate = ServiceRequest.Update(name: "")
//        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
//        
//        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           request: .matching({ $0.name == requestUpdate.name }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)",
//                     beforeRequest: { req in
//            try req.content.encode(requestUpdate)
//        }) { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testUpdate_WithValidName_ShouldReturnService() async throws {
//        
//        // Given
//        let id = UUID()
//        let requestId = GeneralRequest.FetchById(id: id)
//        let requestUpdate = ServiceRequest.Update(name: "Test")
//        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
//        
//        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           request: .matching({ $0.name == requestUpdate.name }),
//                           on: .any).willReturn(Stub.contact)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)",
//                     beforeRequest: { req in
//            try req.content.encode(requestUpdate)
//        }) { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Test")
//        }
//    }
//    
//    // MARK: - Test DELETE /contacts/:id
//    func testDelete_WithInvalidService_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        given(validator).validateID(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.DELETE, "contacts/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testDelete_WithNotExistId_ShouldReturnNotFound() async throws {
//        
//        // Given
//        let id = UUID()
//        let reqId = GeneralRequest.FetchById(id: id)
//        given(validator).validateID(.any).willReturn(reqId)
//        
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willThrow(DefaultError.notFound)
//        
//        try app.test(.DELETE, "contacts/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .notFound)
//        }
//    }
//    
//    func testDelete_WithValidService_ShouldReturnService() async throws {
//        
//        // Given
//        let id = UUID()
//        let reqId = GeneralRequest.FetchById(id: id)
//        given(validator).validateID(.any).willReturn(reqId)
//        
//        let stub = Service(id: .init(),
//                           name: "Name",
//                           createAt: .now,
//                           updatedAt: .now,
//                           deletedAt: .now)
//        given(repo).delete(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.DELETE, "contacts/\(id.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Name")
//            XCTAssertNotNil(group.deletedAt)
//        }
//    }
//    
//    // MARK: - Test GET /contacts/search
//    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let query = GeneralRequest.Search(query: "")
//        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).search(request: .matching({ $0.query == query.query }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.GET, "contacts/search") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testSearch_WithMore200CharQuery_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let query = GeneralRequest.Search(query: String(repeating: "A", count: 210))
//        given(validator).validateSearchQuery(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).search(request: .matching({ $0.query == query.query }),
//                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.GET, "contacts/search?query=\(query.query)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testSearch_WithValidQuery_ShouldReturnEmptyServices() async throws {
//        
//        // Given
//        let query = GeneralRequest.Search(query: "Test")
//        given(validator).validateSearchQuery(.any).willReturn(query)
//        
//        let stub = PaginatedResponse<Service>(page: 1, perPage: 20, total: 0, items: [])
//        given(repo).search(request: .matching({ $0.query == query.query }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.GET, "contacts/search?query=Test") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
//            XCTAssertEqual(groups.total, 0)
//        }
//    }
//    
//    func testSearch_WithValidQuery_ShouldReturnServices() async throws {
//        
//        // Given
//        let query = GeneralRequest.Search(query: "Test")
//        given(validator).validateSearchQuery(.any).willReturn(query)
//        
//        let stub = PaginatedResponse<Service>(page: 1, perPage: 20, total: 2,
//                                              items: [Service(name: "Test 1"),
//                                                      Service(name: "Test 2")])
//        given(repo).search(request: .matching({ $0.query == query.query }),
//                           on: .any).willReturn(stub)
//        
//        try app.test(.GET, "contacts/search?query=Test") { res in
//            XCTAssertEqual(res.status, .ok)
//            let groups = try res.content.decode(PaginatedResponse<ServiceResponse>.self)
//            XCTAssertEqual(groups.total, 2)
//        }
//    }
//    
//    // MARK: - Test GET /contacts/:id/addresses/:address_id
//    func testUpdateBussineseAddress_WithInvalidID_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        let addressID = UUID()
//        let content = ServiceRequest.UpdateBussineseAddress(address: "Address")
//        given(validator).validateUpdateBussineseAddress(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).updateBussineseAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                                           addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
//                                           request: .matching({ $0.address == content.address }),
//                                           on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)/businese_address/\(addressID.uuidString)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testUpdateBussineseAddress_WithValidID_ShouldReturnService() async throws {
//        
//        // Given
//        let id = UUID()
//        let addressID = UUID()
//        let content = ServiceRequest.UpdateBussineseAddress(address: "Address")
//        let response = ServiceRequest.UpdateBusineseAdressResponse(id: .init(id: id),
//                                                                   addressID: .init(id: addressID),
//                                                                   content: content)
//        given(validator).validateUpdateBussineseAddress(.any).willReturn(response)
//        
//        let stub = Service(id: .init(),
//                           name: "Name",
//                           createAt: .now,
//                           updatedAt: .now,
//                           deletedAt: .now)
//        given(repo).updateBussineseAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                                           addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
//                                           request: .matching({ $0.address == content.address }),
//                                           on: .any).willReturn(stub)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)/businese_address/\(addressID.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Name")
//        }
//    }
//    
//    //MARK: - Test GET /contacts/:id/shipping_address/:address_id
//    func testUpdateShippingAddress_WithInvalidID_ShouldReturnBadRequest() async throws {
//        
//        // Given
//        let id = UUID()
//        let addressID = UUID()
//        let content = ServiceRequest.UpdateShippingAddress(address: "Address")
//        given(validator).validateUpdateShippingAddress(.any).willThrow(DefaultError.invalidInput)
//        
//        given(repo).updateShippingAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                                          addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
//                                          request: .matching({ $0.address == content.address }),
//                                          on: .any).willThrow(DefaultError.invalidInput)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)/shipping_address/\(addressID.uuidString)") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testUpdateShippingAddress_WithValidID_ShouldReturnService() async throws {
//        
//        // Given
//        let id = UUID()
//        let addressID = UUID()
//        let content = ServiceRequest.UpdateShippingAddress(address: "Address")
//        let response = ServiceRequest.UpdateShippingAddressResponse(id: .init(id: id),
//                                                                     addressID: .init(id: addressID),
//                                                                     content: content)
//        given(validator).validateUpdateShippingAddress(.any).willReturn(response)
//        
//        let stub = Service(id: .init(),
//                           name: "Name",
//                           createAt: .now,
//                           updatedAt: .now,
//                           deletedAt: .now)
//        given(repo).updateShippingAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
//                                          addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
//                                          request: .matching({ $0.address == content.address }),
//                                          on: .any).willReturn(stub)
//        
//        try app.test(.PUT, "contacts/\(id.uuidString)/shipping_address/\(addressID.uuidString)") { res in
//            XCTAssertEqual(res.status, .ok)
//            let group = try res.content.decode(ServiceResponse.self)
//            XCTAssertEqual(group.name, "Name")
//        }
//    }
//    
//}
//
//extension ServiceControllerTests {
//    struct Stub {
//        
//        static var emptyService: PaginatedResponse<Service> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 0,
//                  items: [])
//        }
//        
//        static var pageService: PaginatedResponse<Service> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 2,
//                  items: [Service(name: "Supplier"),
//                          Service(name: "Manufactor")])
//        }
//        
//        static var pageServiceWithDeleted: PaginatedResponse<Service> {
//            .init(page: 1,
//                  perPage: 10,
//                  total: 3,
//                  items: [Service(name: "Supplier"),
//                          Service(name: "Manufactor"),
//                          Service(name: "Customer",
//                                  deletedAt: .now)])
//        }
//        
//        static var contact: Service {
//            .init(name: "Test")
//        }
//    }
//}
