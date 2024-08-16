//
//  MyBusineseControllerTests.swift
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

final class MyBusineseControllerTests: XCTestCase {
    
    var app: Application!
    var db: Database!
    
    lazy var repo = MockMyBusineseRepositoryProtocol()
    lazy var validator = MockMyBusineseValidatorProtocol()
    
    var controller: MyBusineseController!
    
    // Database configuration
    var dbHost: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: MyBusineseMigration())
        
        db = app.db
        
        try await dropCollection(db,
                                 schema: MyBusinese.schema)
        
        //register service controller
        controller = .init(repository: repo,
                           validator: validator)
        try app.register(collection: controller)
    }
    
    override func tearDown() async throws {
        
        app.shutdown()
        try await super.tearDown()
    }
    
    // MARK: - Tests GET /my_busineses
    func testAll_WithNoRequestParam_ShouldReturnEmptyMyBusineses() async throws {

        // Given
        given(repo).fetchAll(on: .any).willReturn(Stub.emptyMyBusinese)

        try app.test(.GET, "my_busineses") { res in
            XCTAssertEqual(res.status, .ok)
            let items = try res.content.decode([MyBusinese].self)
            XCTAssertEqual(items.count, 0)
        }
    }

    func testAll_WithNoRequestParam_ShouldReturnAllMyBusineses() async throws {

        // Given
        given(repo).fetchAll(on: .any).willReturn(Stub.allMyBusinese)

        try app.test(.GET, "my_busineses") { res in
            XCTAssertEqual(res.status, .ok)
            let items = try res.content.decode([MyBusinese].self)
            XCTAssertEqual(items.count, 1)
        }
    }

    // MARK: - Test GET /my_busineses/:id
    func testGetByID_WithID_ShouldReturnNotFound() async throws {

        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willThrow(DefaultError.notFound)
        given(validator).validateID(.any).willReturn(request)

        try app.test(.GET, "my_busineses/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }

    }

    func testGetByID_WithMatchID_ShouldReturnMyBusinese() async throws {

        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        given(repo).fetchById(request: .matching({ $0.id == id}),
                              on: .any).willReturn(Stub.myBusinese)
        given(validator).validateID(.any).willReturn(request)

        try app.test(.GET, "my_busineses/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let item = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(item.name, "Test")
        }
    }

    // MARK: - Test POST /my_busineses
    func testCreate_WithEmptyMyBusineseName_ShouldReturnBadRequest() async throws {

        // Given
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let request = MyBusineseRequest.Create(
            name: "",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        
        given(validator).validateCreate(.any).willReturn(request)

        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willThrow(DefaultError.insertFailed)

        try app.test(.POST, "my_busineses",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testCreate_WithValidName_ShouldReturnMyBusinese() async throws {

        // Given
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let request = MyBusineseRequest.Create(
            name: "Test",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        
        given(validator).validateCreate(.any).willReturn(request)

        given(repo).create(request: .matching({ $0.name == request.name }),
                           on: .any).willReturn(Stub.myBusinese)

        try app.test(.POST, "my_busineses",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(group.name, "Test")
        }
    }

    func testCreate_WithValidInfo_ShouldReturnMyBusinese() async throws {

        // Given
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let request = MyBusineseRequest.Create(
            name: "Test",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        
        given(validator).validateCreate(.any).willReturn(request)
        
        let stub = MyBusinese(id: .init(),
                              name: request.name,
                              vatRegistered: request.vatRegistered,
                              contactInformation: request.contactInformation,
                              taxNumber: request.taxNumber,
                              legalStatus: request.legalStatus,
                              website: request.website,
                              note: request.note)
        given(repo).create(request: .any,
                           on: .any).willReturn(stub)

        try app.test(.POST, "my_busineses",
                     beforeRequest: { req in
            try req.content.encode(request)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let contact = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(contact.name, "Test")
            XCTAssertEqual(contact.vatRegistered, true)
            XCTAssertEqual(contact.contactInformation, contactInfo)
            XCTAssertEqual(contact.taxNumber, "1234567890123")
            XCTAssertEqual(contact.legalStatus, .individual)
            XCTAssertEqual(contact.website, "https://example.com")
            XCTAssertEqual(contact.note, "Test note")
        }
    }

    // MARK: - Test PUT /my_busineses/:id
    func testUpdate_WithInvalidName_ShouldReturnBadRequest() async throws {

        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = MyBusineseRequest.Update(name: "")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))

        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "my_busineses/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testUpdate_WithValidName_ShouldReturnMyBusinese() async throws {

        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = MyBusineseRequest.Update(name: "Test")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))

        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.name == requestUpdate.name }),
                           on: .any).willReturn(Stub.myBusinese)

        try app.test(.PUT, "my_busineses/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(group.name, "Test")
        }
    }
    
    func testUpdate_WithInvalidTaxNumber_ShouldReturnBadRequest() async throws {

        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = MyBusineseRequest.Update(taxNumber: "123")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))

        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.taxNumber == requestUpdate.taxNumber }),
                           on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "my_busineses/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUpdate_WithValidTaxNumber_ShouldReturnMyBusinese() async throws {

        // Given
        let id = UUID()
        let requestId = GeneralRequest.FetchById(id: id)
        let requestUpdate = MyBusineseRequest.Update(taxNumber: "1234567890123")
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))

        given(repo).update(byId: .matching({ $0.id.uuidString == id.uuidString }),
                           request: .matching({ $0.taxNumber == requestUpdate.taxNumber }),
                           on: .any).willReturn(Stub.myBusinese)

        try app.test(.PUT, "my_busineses/\(id.uuidString)",
                     beforeRequest: { req in
            try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(group.taxNumber, "1234567890123")
        }
    }

    // MARK: - Test GET /my_busineses/:id/addresses/:address_id
    func testUpdateBussineseAddress_WithInvalidID_ShouldReturnBadRequest() async throws {

        // Given
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateBussineseAddress(address: "Address")
        given(validator).validateUpdateBussineseAddress(.any).willThrow(DefaultError.invalidInput)

        given(repo).updateBussineseAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
                                           addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
                                           request: .matching({ $0.address == content.address }),
                                           on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "my_busineses/\(id.uuidString)/businese_address/\(addressID.uuidString)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testUpdateBussineseAddress_WithValidID_ShouldReturnMyBusinese() async throws {

        // Given
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateBussineseAddress(address: "Address")
        let response = MyBusineseRequest.UpdateBusineseAdressResponse(id: .init(id: id),
                                                                   addressID: .init(id: addressID),
                                                                   content: content)
        given(validator).validateUpdateBussineseAddress(.any).willReturn(response)
        
        let stub = MyBusinese(id: .init(),
                              name: "Name",
                              taxNumber: "1234567890123", 
                              createdAt: .now,
                              updatedAt: .now)
        given(repo).updateBussineseAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
                                           addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
                                           request: .matching({ $0.address == content.address }),
                                           on: .any).willReturn(stub)

        try app.test(.PUT, "my_busineses/\(id.uuidString)/businese_address/\(addressID.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(group.name, "Name")
        }
    }

    //MARK: - Test GET /my_busineses/:id/shipping_address/:address_id
    func testUpdateShippingAddress_WithInvalidID_ShouldReturnBadRequest() async throws {

        // Given
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateShippingAddress(address: "Address")
        given(validator).validateUpdateShippingAddress(.any).willThrow(DefaultError.invalidInput)

        given(repo).updateShippingAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
                                          addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
                                          request: .matching({ $0.address == content.address }),
                                          on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "my_busineses/\(id.uuidString)/shipping_address/\(addressID.uuidString)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testUpdateShippingAddress_WithValidID_ShouldReturnMyBusinese() async throws {

        // Given
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateShippingAddress(address: "Address")
        let response = MyBusineseRequest.UpdateShippingAddressResponse(id: .init(id: id),
                                                                     addressID: .init(id: addressID),
                                                                     content: content)
        given(validator).validateUpdateShippingAddress(.any).willReturn(response)

        let stub = MyBusinese(id: .init(),
                              name: "Name",
                              taxNumber: "1234567890123",
                              createdAt: .now)
        given(repo).updateShippingAddress(byId: .matching({ $0.id.uuidString == id.uuidString }),
                                          addressID: .matching({ $0.id.uuidString == addressID.uuidString }),
                                          request: .matching({ $0.address == content.address }),
                                          on: .any).willReturn(stub)

        try app.test(.PUT, "my_busineses/\(id.uuidString)/shipping_address/\(addressID.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let group = try res.content.decode(MyBusinese.self)
            XCTAssertEqual(group.name, "Name")
        }
    }
    
}

extension MyBusineseControllerTests {
    struct Stub {
        
        static var emptyMyBusinese: [MyBusinese] {
            []
        }
        
        static var allMyBusinese: [MyBusinese] {
            [Self.myBusinese]
        }
        
        static var myBusinese: MyBusinese {
            .init(name: "Test",
                  vatRegistered: false,
                  contactInformation: .init(contactPerson: "Contact Person",
                                            phone: "01928384829",
                                            email: "abc@email.com"),
                  taxNumber: "1234567890123",
                  legalStatus: .individual,
                  website: "Website",
                  note: "Note")
            
        }
    }
}
