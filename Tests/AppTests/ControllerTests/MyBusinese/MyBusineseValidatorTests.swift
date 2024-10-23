//
//  MyBusineseValidatorTests.swift
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

final class MyBusineseValidatorTests: XCTestCase {

    var app: Application!
    var validator: MyBusineseValidator!

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
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let content = MyBusineseRequest.Create(
            name: "John Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        let request = mockRequest(content: content)
        
        XCTAssertNoThrow(try validator.validateCreate(request))
    }       

    func testValidateCreate_WithLessThan3CharName_ShouldThrow() {
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let content = MyBusineseRequest.Create(
            name: "AB",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let content = MyBusineseRequest.Create(
            name: name,
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithInvalidTaxNumber_ShouldThrow() {
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let content = MyBusineseRequest.Create(
            name: "Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    // MARK: - Update Tests

    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let contactInfo = ContactInformation(contactPerson: "John doe",
                                             phone: "123456789",
                                             email: "abc@email.com")
        
        let content = MyBusineseRequest.Update(
            name: "John Doe",
            vatRegistered: false,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            logo: "https://example.com",
            stampLogo: "https://example.com",
            authorizedSignSignature: "https://example.com",
            note: "Updated note"
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertNoThrow(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithLessThan3CharName_ShouldThrow() {
        let id = UUID()
        let content = MyBusineseRequest.Update(
            name: "Do"
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithOver200CharName_ShouldThrow() {
        let id = UUID()
        let name = String(repeating: "A", count: 201)
        let content = MyBusineseRequest.Update(
            name: name
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }
    
    func testValidateUpdate_WithInvalidTaxNumber_ShouldThrow() {
        let id = UUID()
        let content = MyBusineseRequest.Update(
            taxNumber: "123"
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    // MARK: - Update Business Address Tests

    func testValidateUpdateBussineseAddress_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateBussineseAddress(
            address: "123 Main St",
            branch: nil,
            branchCode: nil,
            subDistrict: nil,
            district: nil,
            province: nil,
            country: nil,
            postalCode: nil,
            phone: nil,
            email: nil,
            fax: nil
        )
        let request = mockRequest(url: "/mock/:id/address/:address_id", pathParameters: ["id": id, "address_id": addressID], content: content)

        XCTAssertNoThrow(try validator.validateUpdateBussineseAddress(request))
    }
    
    func testValidateUpdateBussineseAddress_WithInvalidPostCodeRequest_ShouldThrow() throws {
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateBussineseAddress(
            address: nil,
            branch: nil,
            branchCode: nil,
            subDistrict: nil,
            district: nil,
            province: nil,
            country: nil,
            postalCode: "2929283833",
            phone: nil,
            email: nil,
            fax: nil
        )
        let request = mockRequest(url: "/mock/:id/address/:address_id", 
                                  pathParameters: [
                                    "id": id,
                                    "address_id": addressID
                                  ],
                                  content: content)

        XCTAssertThrowsError(try validator.validateUpdateBussineseAddress(request))
    }

    // MARK: - Update Shipping Address Tests

    func testValidateUpdateShippingAddress_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateShippingAddress(
            address: "123 Main St",
            subDistrict: nil,
            district: nil,
            province: nil,
            country: nil,
            postalCode: nil,
            phone: nil
        )
        let request = mockRequest(url: "/mock/:id/address/:address_id", pathParameters: ["id": id, "address_id": addressID], content: content)

        XCTAssertNoThrow(try validator.validateUpdateShippingAddress(request))
    }

    func testValidateUpdateShippingAddress_WithInvalidPostCodeRequest_ShouldThrow() throws {
        let id = UUID()
        let addressID = UUID()
        let content = MyBusineseRequest.UpdateShippingAddress(
            address: nil,
            subDistrict: nil,
            district: nil,
            province: nil,
            country: nil,
            postalCode: "2929283833",
            phone: nil
        )
        let request = mockRequest(url: "/mock/:id/address/:address_id",
                                  pathParameters: [
                                    "id": id,
                                    "address_id": addressID
                                  ],
                                  content: content)

        XCTAssertThrowsError(try validator.validateUpdateShippingAddress(request))
    }
    
    // MARK: - Fetch By ID Tests

    func testValidateID_WithValidRequest_ShouldReturnCorrectValues() {
        let id = UUID()
        let request = mockRequest(url: "/mock/:id",
                                  pathParameters: ["id": id])

        XCTAssertNoThrow(try validator.validateID(request))
    }

    func testValidateID_WithInvalidID_ShouldThrow() {
        let request = mockGETRequest(url: "contacts/invalid")

        XCTAssertThrowsError(try validator.validateID(request))
    }

}
