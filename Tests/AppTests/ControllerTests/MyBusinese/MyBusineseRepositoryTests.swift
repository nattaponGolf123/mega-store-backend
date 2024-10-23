//
//  MyBusineseRepositoryTests.swift
//
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import MockableTest

@testable import App

final class MyBusineseRepositoryTests: XCTestCase {

    var app: Application!
    var db: Database!
    
    // Database configuration
    var dbHost: String!

    private(set) var myBusineseRepository: MyBusineseRepository!

    override func setUp() async throws {
        try await super.setUp()

        app = Application(.testing)
        dbHost = try dbHostURL(app)
        
        try configure(app,
                      dbHost: dbHost,
                      migration: MyBusineseMigration())
        
        db = app.db
        
        myBusineseRepository = MyBusineseRepository()

        // Drop collection if needed before starting the tests
        try await dropCollection(db, 
                                 schema: MyBusinese.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Fetch All Tests

    func testFetchAll_ShouldReturnAllMyBusineses() async throws {
        // Given
        let businese1 = MyBusinese(name: "Business 1", vatRegistered: false, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .individual, website: nil, note: nil)
        let businese2 = MyBusinese(name: "Business 2", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890124", legalStatus: .companyLimited, website: "example.com", note: "Test Note")
        
        try await businese1.save(on: db)
        try await businese2.save(on: db)

        // When
        let result = try await myBusineseRepository.fetchAll(on: db)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.name, "Business 1")
    }

    // MARK: - Fetch By ID Tests

    func testFetchById_ShouldReturnBusinese() async throws {
        // Given
        let businese = MyBusinese(name: "Business", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .companyLimited, website: "example.com", note: "Test Note")
        try await businese.save(on: db)

        // When
        let result = try await myBusineseRepository.fetchById(request: .init(id: businese.id!), on: db)

        // Then
        XCTAssertEqual(result.name, "Business")
    }

    func testFetchById_NotFound_ShouldThrowError() async throws {
        // Given
        let nonExistentID = UUID()

        // When
        do {
            _ = try await myBusineseRepository.fetchById(request: .init(id: nonExistentID), on: db)
            XCTFail("Expected to throw error but didn't.")
        } catch {
            XCTAssertEqual(error as? DefaultError, DefaultError.notFound)
        }
    }

    // MARK: - Create Tests

    func testCreate_ShouldCreateBusinese() async throws {
        // Given
        let request = MyBusineseRequest.Create(name: "Business", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .companyLimited, website: "example.com", note: "Test Note")

        // When
        let result = try await myBusineseRepository.create(request: request, on: db)

        // Then
        XCTAssertEqual(result.name, "Business")
        XCTAssertEqual(result.vatRegistered, true)
        XCTAssertEqual(result.taxNumber, "1234567890123")
        XCTAssertEqual(result.legalStatus, .companyLimited)
        XCTAssertEqual(result.website, "example.com")
        XCTAssertEqual(result.note, "Test Note")
    }

    func testCreate_DuplicateName_ShouldThrowError() async throws {
        // Given
        let existingBusinese = MyBusinese(name: "Business", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .companyLimited, website: "example.com", note: "Test Note")
        try await existingBusinese.save(on: db)

        let request = MyBusineseRequest.Create(name: "Business", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890124", legalStatus: .individual, website: nil, note: nil)

        // When
        do {
            _ = try await myBusineseRepository.create(request: request, on: db)
            XCTFail("Expected to throw error but didn't.")
        } catch {
            XCTAssertEqual(error as? CommonError, CommonError.duplicateName)
        }
    }

    // MARK: - Update Tests

    func testUpdate_WithValidData_ShouldUpdateBusinese() async throws {
        // Given
        let businese = MyBusinese(name: "Old Business", vatRegistered: false, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .individual, website: nil, note: nil)
        try await businese.save(on: db)

        let request = MyBusineseRequest.Update(name: "Updated Business", 
                                               vatRegistered: true,
                                               contactInformation: .init(contactPerson: "A",
                                                                         phone: "phone",
                                                                         email: "email"),
                                               taxNumber: "1234567890123",
                                               legalStatus: .companyLimited,
                                               website: "updated.com",
                                               note: "Updated Note")

        // When
        let result = try await myBusineseRepository.update(byId: .init(id: businese.id!), request: request, on: db)

        // Then
        XCTAssertEqual(result.name, "Updated Business")
        XCTAssertEqual(result.vatRegistered, true)
        XCTAssertEqual(result.website, "updated.com")
        XCTAssertEqual(result.note, "Updated Note")
    }

    func testUpdate_WithDuplicateName_ShouldThrowError() async throws {
        // Given
        let businese1 = MyBusinese(name: "Business1", vatRegistered: false, contactInformation: nil, taxNumber: "1234567890123", legalStatus: .individual, website: nil, note: nil)
        let businese2 = MyBusinese(name: "Business2", vatRegistered: true, contactInformation: nil, taxNumber: "1234567890124", legalStatus: .companyLimited, website: nil, note: nil)
        try await businese1.save(on: db)
        try await businese2.save(on: db)

        let request = MyBusineseRequest.Update(name: "Business2")

        // When
        do {
            _ = try await myBusineseRepository.update(byId: .init(id: businese1.id!), request: request, on: db)
            XCTFail("Expected to throw error but didn't.")
        } catch {
            XCTAssertEqual(error as? CommonError, CommonError.duplicateName)
        }
    }

    // MARK: - Update Business Address Tests

    func testUpdateBusinessAddress_ShouldUpdateAddress() async throws {
        // Given
        
        var address = BusinessAddress(id: UUID(),
                                      branch: "Branch",
                                      address: "Address")
        let businese = MyBusinese(name: "Business",
                                  vatRegistered: true,
                                  contactInformation: nil,
                                  taxNumber: "1234567890123",
                                  legalStatus: .companyLimited,
                                  website: nil,
                                  businessAddress: [address], 
                                  note: nil)
        try await businese.save(on: db)

        let request = MyBusineseRequest.UpdateBussineseAddress(address: "New Address",
                                                               branch: "New Branch",
                                                               branchCode: nil,
                                                               subDistrict: nil,
                                                               district: nil,
                                                               province: nil,
                                                               country: nil,
                                                               postalCode: nil,
                                                               phone: nil,
                                                               email: nil,
                                                               fax: nil)

        // When
        let result = try await myBusineseRepository.updateBussineseAddress(byId: .init(id: businese.id!),
                                                                           addressID: .init(id: address.id),
                                                                           request: request, on: db)

        // Then
        XCTAssertEqual(result.businessAddress.first?.address, "New Address")
        XCTAssertEqual(result.businessAddress.first?.branch, "New Branch")
    }

    // MARK: - Update Shipping Address Tests

    func testUpdateShippingAddress_ShouldUpdateAddress() async throws {
        // Given
        var address = ShippingAddress(id: UUID(), 
                                      address: "Old Shipping Address",
                                      phone: "123-456-789")
        let businese = MyBusinese(name: "Business",
                                  vatRegistered: true,
                                  contactInformation: nil,
                                  taxNumber: "1234567890123",
                                  legalStatus: .companyLimited,
                                  website: nil,
                                  shippingAddress: [address],
                                  note: nil)
        try await businese.save(on: db)

        let request = MyBusineseRequest.UpdateShippingAddress(address: "New Shipping Address",
                                                              phone: "987-654-321")

        // When
        let result = try await myBusineseRepository.updateShippingAddress(byId: .init(id: businese.id!),
                                                                          addressID: .init(id: address.id),
                                                                          request: request, on: db)

        // Then
        XCTAssertEqual(result.shippingAddress.first?.address, "New Shipping Address")
        XCTAssertEqual(result.shippingAddress.first?.phone, "987-654-321")
    }
}
