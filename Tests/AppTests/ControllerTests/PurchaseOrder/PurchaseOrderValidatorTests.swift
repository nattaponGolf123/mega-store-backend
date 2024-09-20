//
//  PurchaseOrderValidatorTests.swift
//
//
//  Created by [Your Name] on [Date].
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import Mockable
import MockableTest

@testable import App

final class PurchaseOrderValidatorTests: XCTestCase {
    
    var app: Application!
    
    var validator: PurchaseOrderValidator!
    
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
        let items = [PurchaseOrderRequest.CreateItem(itemId: UUID(),
                                                     kind: .product,
                                                     name: "Test Product",
                                                     description: "Test Description",
                                                     variantId: nil,
                                                     qty: 10.0,
                                                     pricePerUnit: 100.0,
                                                     discountPricePerUnit: 10.0,
                                                     vatRateOption: .vat7,
                                                     vatIncluded: true,
                                                     withholdingTaxRateOption: .tax3)]
        
        let content = PurchaseOrderRequest.Create(reference: "PO-12345",
                                                  note: "Test Note",
                                                  supplierId: UUID(),
                                                  customerId: UUID(),
                                                  orderDate: Date(),
                                                  deliveryDate: Date(),
                                                  paymentTermsDays: 30,
                                                  items: items,
                                                  additionalDiscountAmount: 50.0,
                                                  vatOption: .vatIncluded,
                                                  includedVat: true,
                                                  currency: .thb)
        let request = mockRequest(content: content)
        
        XCTAssertNoThrow(try validator.validateCreate(request))
    }
    
    func testValidateCreate_WithMissingItems_ShouldThrowError() {
        let content = PurchaseOrderRequest.Create(reference: "PO-12345",
                                                  note: "Test Note",
                                                  supplierId: UUID(),
                                                  customerId: UUID(),
                                                  orderDate: Date(),
                                                  deliveryDate: Date(),
                                                  paymentTermsDays: 30,
                                                  items: [],
                                                  additionalDiscountAmount: 50.0,
                                                  vatOption: .vatIncluded,
                                                  includedVat: true,
                                                  currency: .thb)
        let request = mockRequest(content: content)
        
        XCTAssertThrowsError(try validator.validateCreate(request))
    }
    
    // MARK: - Update Tests
    
    func testValidateUpdate_WithValidRequest_ShouldReturnCorrectValues() throws {
        let id = UUID()
        let items = [PurchaseOrderRequest.UpdateItem(id: UUID(),
                                                     itemId: UUID(),
                                                     kind: .product,
                                                     name: "Updated Product",
                                                     description: "Updated Description",
                                                     variantId: nil,
                                                     qty: 5.0,
                                                     pricePerUnit: 50.0,
                                                     discountPricePerUnit: 5.0,
                                                     vatRateOption: .vat7,
                                                     vatIncluded: true,
                                                     withholdingTaxRateOption: .tax3)]
        
        let content = PurchaseOrderRequest.Update(reference: "PO-12345-Updated",
                                                  note: "Updated Note",
                                                  paymentTermsDays: 15,
                                                  supplierId: UUID(),
                                                  deliveryDate: Date(),
                                                  items: items,
                                                  vatOption: .vatIncluded,
                                                  orderDate: Date(),
                                                  additionalDiscountAmount: 25.0,
                                                  currency: .thb,
                                                  includedVat: true)
        let request = mockRequest(url: "/purchase-order/:id",
                                  pathParameters: ["id": id],
                                  content: content)
        
        XCTAssertNoThrow(try validator.validateUpdate(request))
    }
    
    func testValidateUpdate_WithNoId_ShouldThrowError() {
        let content = PurchaseOrderRequest.Update(reference: "PO-12345-Updated",
                                                  note: "Updated Note",
                                                  paymentTermsDays: 15,
                                                  supplierId: UUID(),
                                                  deliveryDate: Date(),
                                                  items: nil,
                                                  vatOption: .vatIncluded,
                                                  orderDate: Date(),
                                                  additionalDiscountAmount: 25.0,
                                                  currency: .thb,
                                                  includedVat: true)
        let request = mockRequest(url: "/purchase-order/:id",
                                  pathParameters: ["id": .init()],
                                  content: content)
        
        XCTAssertThrowsError(try validator.validateUpdate(request))
    }
    
    // MARK: - Search Query Tests
    
    func testValidateSearchQuery_WithValidRequest_ShouldReturnCorrectValues() {
        let content = PurchaseOrderRequest.Search(query: "Test", periodDate: PeriodDate(from: Date(), to: Date()))
        let request = mockGETRequest(param: content)
        
        XCTAssertNoThrow(try validator.validateSearchQuery(request))
    }
    
    func testValidateSearchQuery_WithEmptyQuery_ShouldThrow() {
        let content = PurchaseOrderRequest.Search(query: "", periodDate: PeriodDate(from: Date(), to: Date()))
        let request = mockGETRequest(param: content)
        
        XCTAssertThrowsError(try validator.validateSearchQuery(request))
    }
    
    // MARK: - Fetch Query Tests
    
    func testValidateFetchQuery_WithValidRequest_ShouldReturnCorrectValues() {
        let content = PurchaseOrderRequest.FetchAll(status: .all, periodDate: PeriodDate(from: Date(), to: Date()))
        let request = mockGETRequest(param: content)
        
        XCTAssertNoThrow(try validator.validateFetchQuery(request))
    }
    
    // MARK: - Replace Items Tests
    
    func testValidateReplaceItems_WithValidRequest_ShouldReturnCorrectValues() {
        let items = [PurchaseOrderRequest.CreateItem(itemId: UUID(),
                                                     kind: .product,
                                                     name: "Test Product",
                                                     description: "Test Description",
                                                     variantId: nil,
                                                     qty: 10.0,
                                                     pricePerUnit: 100.0,
                                                     discountPricePerUnit: 10.0,
                                                     vatRateOption: .vat7,
                                                     vatIncluded: true,
                                                     withholdingTaxRateOption: .tax3)]
        
        let content = PurchaseOrderRequest.ReplaceItems(items: items,
                                                        vatOption: .vatIncluded,
                                                        additionalDiscountAmount: 50.0,
                                                        includedVat: true)
        
        let request = mockRequest(url: "/purchase-order/:id/replace-items",
                                  pathParameters: ["id": .init()],
                                  content: content)
        
        XCTAssertNoThrow(try validator.validateReplaceItems(request))
    }
    
    func testValidateReplaceItems_WithEmptyItems_ShouldThrowError() {
        let content = PurchaseOrderRequest.ReplaceItems(items: [],
                                                        vatOption: .vatIncluded,
                                                        additionalDiscountAmount: 50.0,
                                                        includedVat: true)
        
        let request = mockRequest(url: "/purchase-order/:id/replace-items",
                                  pathParameters: ["id": .init()],
                                  content: content)
        
        XCTAssertThrowsError(try validator.validateReplaceItems(request))
    }
    
    // MARK: - Reorder Items Tests
    
    func testValidateReorderItems_WithValidRequest_ShouldReturnCorrectValues() {
        let content = PurchaseOrderRequest.ReorderItems(itemIdOrder: [UUID(), UUID()])
        let request = mockRequest(url: "/purchase-order/:id/reorder-items",
                                  pathParameters: ["id": .init()],
                                  content: content)
        
        XCTAssertNoThrow(try validator.validateReorderItems(request))
    }
    
    func testValidateReorderItems_WithEmptyItemIdOrder_ShouldThrowError() {
        let content = PurchaseOrderRequest.ReorderItems(itemIdOrder: [])
        let request = mockRequest(url: "/purchase-order/:id/reorder-items",
                                  pathParameters: ["id": .init()],
                                  content: content)
        
        XCTAssertThrowsError(try validator.validateReorderItems(request))
    }
    
}
