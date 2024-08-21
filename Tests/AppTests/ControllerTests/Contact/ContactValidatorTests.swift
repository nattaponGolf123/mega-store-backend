//
//  ContactValidatorTests.swift
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

final class ContactValidatorTests: XCTestCase {

    var app: Application!
    var validator: ContactValidator!

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
        let content = ContactRequest.Create(
            name: "Test",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "A note",
            groupId: nil,
            paymentTermsDays: 30
        )
        let request = mockRequest(content: content)
        
        XCTAssertNoThrow(try validator.validateCreate(request))
    }       

    func testValidateCreate_WithLessThan3CharName_ShouldThrow() {
        let content = ContactRequest.Create(
            name: "Te",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "A note",
            groupId: nil,
            paymentTermsDays: 30
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = ContactRequest.Create(
            name: name,
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "A note",
            groupId: nil,
            paymentTermsDays: 30
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    func testValidateCreate_WithInvalidTaxNumber_ShouldThrow() {
        let content = ContactRequest.Create(
            name: "Test",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "A note",
            groupId: nil,
            paymentTermsDays: 30
        )
        let request = mockRequest(content: content)

        XCTAssertThrowsError(try validator.validateCreate(request))
    }

    // MARK: - Update Tests

    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let content = ContactRequest.Update(
            name: "Test",
            vatRegistered: nil,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: nil,
            website: nil,
            note: nil,
            paymentTermsDays: nil,
            groupId: nil
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertNoThrow(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithLessThan3CharName_ShouldThrow() {
        let id = UUID()
        let content = ContactRequest.Update(
            name: "T",
            vatRegistered: nil,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: nil,
            website: nil,
            note: nil,
            paymentTermsDays: nil,
            groupId: nil
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithOver200CharName_ShouldThrow() {
        let id = UUID()
        let name = String(repeating: "A", count: 201)
        let content = ContactRequest.Update(
            name: name,
            vatRegistered: nil,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: nil,
            website: nil,
            note: nil,
            paymentTermsDays: nil,
            groupId: nil
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertThrowsError(try validator.validateUpdate(request))
    }

    func testValidateUpdate_WithOnlyDescription_ShouldNotThrow() {
        let id = UUID()
        let content = ContactRequest.Update(
            name: nil,
            vatRegistered: nil,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: nil,
            website: nil,
            note: "A description",
            paymentTermsDays: nil,
            groupId: nil
        )
        let request = mockRequest(url: "/mock/:id", pathParameters: ["id": id], content: content)

        XCTAssertNoThrow(try validator.validateUpdate(request))
    }

    // MARK: - Update Business Address Tests

    func testValidateUpdateBussineseAddress_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let addressID = UUID()
        let content = ContactRequest.UpdateBussineseAddress(
            address: "123 Main St",
            branch: nil,
            branchCode: nil,
            subDistrict: nil,
            city: nil,
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
        let content = ContactRequest.UpdateBussineseAddress(
            address: nil,
            branch: nil,
            branchCode: nil,
            subDistrict: nil,
            city: nil,
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
        let content = ContactRequest.UpdateShippingAddress(
            address: "123 Main St",
            subDistrict: nil,
            city: nil,
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
        let content = ContactRequest.UpdateShippingAddress(
            address: nil,
            subDistrict: nil,
            city: nil,
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
                                  pathParameters: [
                                    "id": id
                                  ])

        XCTAssertNoThrow(try validator.validateID(request))
    }

    func testValidateID_WithInvalidID_ShouldThrow() {
        let request = mockGETRequest(url: "contacts/invalid")

        XCTAssertThrowsError(try validator.validateID(request))
    }

    // MARK: - Search Query Tests

    typealias Search = GeneralRequest.Search

    func testValidateSearchQuery_WithValidRequest_ShouldReturnCorrectValues() {
        let content = Search(query: "Test")
        let request = mockGETRequest(param: content)

        XCTAssertNoThrow(try validator.validateSearchQuery(request))
    }

    func testValidateSearchQuery_WithEmptyCharName_ShouldThrow() {
        let content = Search(query: "")
        let request = mockGETRequest(param: content)

        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }

    func testValidateSearchQuery_WithOver200CharName_ShouldThrow() {
        let name = String(repeating: "A", count: 201)
        let content = Search(query: name)
        let request = mockGETRequest(param: content)

        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }
}
