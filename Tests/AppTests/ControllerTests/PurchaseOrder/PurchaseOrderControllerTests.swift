//
//  PurchaseOrderControllerTests.swift
//
//
//  Created by IntrodexMac on 22/9/2567 BE.
//

import Fluent
import FluentMongoDriver
import Mockable
import MockableTest
import Vapor
import XCTest

@testable import App

final class PurchaseOrderControllerTests: XCTestCase {

    var app: Application!
    var db: Database!

    lazy var repo = MockPurchaseOrderRepositoryProtocol()
    lazy var validator = MockPurchaseOrderValidatorProtocol()
    lazy var generalValidator = MockGeneralValidatorProtocol()
    lazy var jwtValidator = MockJWTValidatorProtocol()

    var controller: PurchaseOrderController!

    // Database configuration
    var dbHost: String!

    override func setUp() async throws {
        try await super.setUp()

        app = Application(.testing)
        dbHost = try dbHostURL(app)
        try configure(
            app,
            dbHost: dbHost,
            migration: PurchaseOrderMigration())

        db = app.db

        // Register purchase order controller
        controller = .init(
            repository: repo,
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)
        try app.register(collection: controller)

        // Drop tables
        try await dropCollection(db, schema: PurchaseOrder.schema)
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - Tests GET /purchase_orders
    func testAll_WithNoRequestParam_ShouldReturnEmptyOrders() async throws {

        // Given
        given(repo).fetchAll(request: .any, on: .any).willReturn(Stub.emptyPagePurchaseOrder)

        try app.test(.GET, "purchase_orders") { res in
            XCTAssertEqual(res.status, .ok)
            let orders = try res.content.decode(PaginatedResponse<PurchaseOrderResponse>.self)
            XCTAssertEqual(orders.items.count, 0)
        }
    }

    func testAll_WithValidRequest_ShouldReturnAllOrders() async throws {

        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po1 = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        let po2 = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )

        try await po1.create(on: db)
        try await po2.create(on: db)

        //given(repo).fetchAll(request: .any, on: .any).willReturn(Stub.pagePurchaseOrder)

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)
        let request = PurchaseOrderRequest.FetchAll(
            status: .all,
            page: 1,
            perPage: 20,
            periodDate: .init(
                from: Date().addingTimeInterval(-86400),
                to: Date().addingTimeInterval(86400))
        )

        try app.test(
            .GET, "purchase_orders",
            beforeRequest: { req in
                try req.content.encode(request)
            }
        ) { res in
            XCTAssertEqual(res.status, .ok)
            let orders = try res.content.decode(PaginatedResponse<PurchaseOrderResponse>.self)
            XCTAssertEqual(orders.items.count, 2)
        }
    }

    // MARK: - Test GET /purchase_orders/:id
    func testGetByID_WithInvalidID_ShouldReturnNotFound() async throws {

        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)

        given(generalValidator).validateID(.any).willReturn(request)
        given(repo).fetchById(request: .matching({ $0.id == id }), on: .any).willThrow(
            DefaultError.notFound)

        try app.test(.GET, "purchase_orders/\(id.uuidString)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }

    func testGetByID_WithValidID_ShouldReturnOrder() async throws {

        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po1 = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        po1.reference = "PO-12345"

        try await po1.create(on: db)

        given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po1.id!))

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.GET, "purchase_orders/\(po1.id!.uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, "PO-12345")
        }
    }

    // MARK: - Test POST /purchase_orders
    func testCreate_WithInvalidOrder_ShouldReturnBadRequest() async throws {

        // Given
        let request = PurchaseOrderRequest.Create(
            reference: "",
            note: "",
            supplierId: UUID(),
            customerId: UUID(),
            orderDate: Date(),
            deliveryDate: Date(),
            paymentTermsDays: 30,
            items: [],
            additionalDiscountAmount: 0,
            vatOption: .vatIncluded,
            includedVat: true,
            currency: .thb)

        given(validator).validateCreate(.any).willThrow(DefaultError.error(message: "Stub Error"))
        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        try app.test(
            .POST, "purchase_orders",
            beforeRequest: { req in
                try req.content.encode(request)
            }
        ) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testCreate_WithValidOrder_ShouldReturnOrder() async throws {

        // Given
        let user = User(
            id: UUID(),
            username: "testuser",
            passwordHash: "hashedPassword",
            token: "token123",
            tokenExpried: Date().addingTimeInterval(3600))
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        //given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po1.id!))
        let items: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: product.id!,
                kind: .product,
                itemName: product.name,
                itemDescription: product.description,
                variantId: nil,
                qty: 1,
                pricePerUnit: 100,
                discountPricePerUnit: 0,
                vatRateOption: .none,
                vatIncluded: false,
                withholdingTaxRateOption: .none)
        ]
        let request = PurchaseOrderRequest.Create(
            reference: "PO-12345",
            note: "Sample note",
            supplierId: contact.id!,
            customerId: customer.id!,
            orderDate: Date(),
            deliveryDate: Date(),
            paymentTermsDays: 30,
            items: items,
            additionalDiscountAmount: 0,
            vatOption: .vatIncluded,
            includedVat: true,
            currency: .thb)

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        given(validator).validateCreate(.any).willReturn(request)

        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        try app.test(
            .POST, "purchase_orders",
            beforeRequest: { req in
                try req.content.encode(request)
            }
        ) { res in
            XCTAssertEqual(res.status, .ok)

            do {
                let response = try res.content.decode(PurchaseOrderResponse.self)
                XCTAssertEqual(response.reference, "PO-12345")
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Test PUT /purchase_orders/:id
    func testUpdate_WithInvalidOrder_ShouldReturnBadRequest() async throws {

        // Given
        let id = UUID()
        let requestUpdate = PurchaseOrderRequest.Update(
            reference: nil,
            note: nil,
            paymentTermsDays: nil,
            supplierId: nil,
            deliveryDate: nil,
            vatOption: nil,
            orderDate: nil,
            additionalDiscountAmount: nil,
            currency: nil,
            includedVat: nil
        )

        let fetchById = GeneralRequest.FetchById(id: id)
        given(validator).validateUpdate(.any).willReturn((fetchById, requestUpdate))

        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        given(repo).update(
            byId: .any,
            request: .any,
            userId: .any,
            on: .any
        ).willThrow(DefaultError.invalidInput)

        try app.test(
            .PUT, "purchase_orders/\(id.uuidString)",
            beforeRequest: { req in
                try req.content.encode(requestUpdate)
            }
        ) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testUpdate_WithValidOrder_ShouldReturnOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let contact2 = Stub.supplier2
        let customer = Stub.customer
        let product = Product(name: "Product A")

        let po = PurchaseOrder(
            month: 1,
            year: 2024,
            number: 1,
            reference: nil,
            vatOption: .noVat,
            includedVat: false,
            items: [
                .init(
                    itemId: product.id!,
                    kind: .product,
                    itemName: product.name,
                    itemDescription: product.descriptionInfo ?? "",
                    variantId: nil,
                    qty: 1,
                    pricePerUnit: 100,
                    discountPricePerUnit: 0,
                    additionalDiscount: 0,
                    vatRateOption: .none,
                    vatIncluded: false,
                    taxWithholdingRateOption: .none)
            ],
            additionalDiscountAmount: 0,
            orderDate: .init(),
            deliveryDate: .init(),
            paymentTermsDays: 30,
            supplierId: contact.id!,
            customerId: customer.id!,
            currency: .thb,
            note: "Note",
            userId: user.id!)

        try await user.create(on: db)
        try await contact.create(on: db)
        try await contact2.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)
        try await po.create(on: db)

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        let updateDate = Date().addingTimeInterval(86400)
        let requestId = GeneralRequest.FetchById(id: po.id!)
        let requestUpdate = PurchaseOrderRequest.Update(
            reference: "PO-12345",
            note: "Sample note",
            paymentTermsDays: 15,
            supplierId: contact2.id!,
            deliveryDate: updateDate,
            vatOption: .vatExcluded,
            orderDate: updateDate,
            additionalDiscountAmount: 10,
            currency: nil,
            includedVat: true
        )
            
        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))

        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        //        let purchaseOrder = PurchaseOrder(id: UUID(), reference: "PO-12345")
        //        try await purchaseOrder.save(on: db)
        //
        //        // Given
        //        let requestUpdate = PurchaseOrderRequest.Update(reference: "Updated PO-12345")
        //        let requestId = GeneralRequest.FetchById(id: purchaseOrder.id!)
        //
        //        given(validator).validateUpdate(.any).willReturn((requestId, requestUpdate))
        //
        
        
        try app.test(.PUT, "purchase_orders/\(po.id!)",
                     beforeRequest: { req in
            //try req.content.encode(requestUpdate)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, "PO-12345")
            XCTAssertEqual(response.note, "Sample note")
            XCTAssertEqual(response.paymentTermsDays, 15)
            XCTAssertEqual(response.supplier?.id, contact2.id)
            XCTAssertEqual(response.deliveryDate, updateDate)
            XCTAssertEqual(response.vatOption, .vatExcluded)
            XCTAssertEqual(response.orderDate, updateDate)
            XCTAssertEqual(response.additionalDiscountAmount, 10)
            XCTAssertEqual(response.includedVat, true)
        }
    }
    //
    //    // MARK: - Test DELETE /purchase_orders/:id
    //    func testDelete_WithInvalidOrder_ShouldReturnBadRequest() async throws {
    //
    //        // Given
    //        let id = UUID()
    //
    //        let request = GeneralRequest.FetchById(id: id)
    //        given(generalValidator).validateID(.any).willReturn(request)
    //        given(repo).delete(byId: .any, on: .any).willThrow(DefaultError.invalidInput)
    //
    //        try app.test(.DELETE, "purchase_orders/\(id.uuidString)") { res in
    //            XCTAssertEqual(res.status, .badRequest)
    //        }
    //    }
    //
    //    func testDelete_WithValidOrder_ShouldReturnOrder() async throws {
    //
    //        let purchaseOrder = PurchaseOrder(id: UUID(), reference: "PO-12345")
    //        try await purchaseOrder.save(on: db)
    //
    //        // Given
    //        let request = GeneralRequest.FetchById(id: purchaseOrder.id!)
    //        given(generalValidator).validateID(.any).willReturn(request)
    //
    //        try app.test(.DELETE, "purchase_orders/\(purchaseOrder.id!.uuidString)") { res in
    //            XCTAssertEqual(res.status, .ok)
    //        }
    //    }
    //
    //    // MARK: - Test GET /purchase_orders/search
    //    func testSearch_WithEmptyQuery_ShouldReturnBadRequest() async throws {
    //        // Given
    //        let request = PurchaseOrderRequest.Search(query: "")
    //        given(validator).validateSearchQuery(.any).willReturn(request)
    //        given(repo).search(request: .any, on: .any).willThrow(DefaultError.invalidInput)
    //
    //        try app.test(.GET, "purchase_orders/search") { res in
    //            XCTAssertEqual(res.status, .badRequest)
    //        }
    //    }
    //
    //    func testSearch_WithValidQuery_ShouldReturnOrders() async throws {
    //
    //        // Given
    //        let order1 = PurchaseOrder(id: UUID(), reference: "PO-12345")
    //        let order2 = PurchaseOrder(id: UUID(), reference: "PO-67890")
    //
    //        try await order1.save(on: db)
    //        try await order2.save(on: db)
    //
    //        let query = PurchaseOrderRequest.Search(query: "PO")
    //        given(validator).validateSearchQuery(.any).willReturn(query)
    //
    //        try app.test(.GET, "purchase_orders/search?query=PO") { res in
    //            XCTAssertEqual(res.status, .ok)
    //            let orders = try res.content.decode(PaginatedResponse<PurchaseOrderResponse>.self)
    //            XCTAssertEqual(orders.total, 2)
    //        }
    //    }
}

//extension PurchaseOrderControllerTests {
//    struct Stub {
//
//        static var emptyPagePurchaseOrder: PaginatedResponse<PurchaseOrder> {
//            .init(page: 1, perPage: 10, total: 0, items: [])
//        }
//
//        static var pagePurchaseOrder: PaginatedResponse<PurchaseOrder> {
//            .init(page: 1, perPage: 10, total: 2, items: [
//                PurchaseOrder(id: UUID(), reference: "PO-12345"),
//                PurchaseOrder(id: UUID(), reference: "PO-67890")
//            ])
//        }
//
//        static var purchaseOrder: PurchaseOrder {
//            .init(id: UUID(), reference: "PO-12345")
//        }
//    }
//}

// MARK: - Stub Data

extension PurchaseOrderControllerTests {
    fileprivate struct Stub {

        static var emptyPagePurchaseOrder: PaginatedResponse<PurchaseOrder> {
            .init(page: 1, perPage: 10, total: 0, items: [])
        }

        static var pagePurchaseOrder: PaginatedResponse<PurchaseOrder> {
            .init(
                page: 1,
                perPage: 10,
                total: 2,
                items: [
                    PurchaseOrder(
                        month: 1,
                        year: 2024,
                        vatOption: .noVat,
                        includedVat: false,
                        items: [],
                        supplierId: .init(),
                        customerId: .init(),
                        userId: .init()),
                    PurchaseOrder(
                        month: 2,
                        year: 2024,
                        vatOption: .noVat,
                        includedVat: false,
                        items: [],
                        supplierId: .init(),
                        customerId: .init(),
                        userId: .init()),
                ])
        }

        static func createPo(
            user: User,
            supplier: Contact,
            customer: MyBusinese,
            product: Product
        ) -> PurchaseOrder {
            let items = Self.createPurchaseOrderItems(product: product)

            return PurchaseOrder(
                month: 9,
                year: 2023,
                number: 1,
                reference: "PO-001",
                vatOption: .vatIncluded,
                includedVat: true,
                items: items,
                additionalDiscountAmount: 0,
                orderDate: Date(),
                deliveryDate: Date().addingTimeInterval(86400),
                paymentTermsDays: 30,
                supplierId: supplier.id!,
                customerId: customer.id!,
                currency: .thb,
                note: "Test Purchase Order",
                userId: user.id!
            )
        }

        static func createPurchaseOrderItems(product: Product) -> [PurchaseOrderItem] {
            return [
                PurchaseOrderItem(
                    itemId: product.id!,
                    kind: .product,
                    itemName: product.name,
                    itemDescription: product.description,
                    variantId: nil,
                    qty: 1,
                    pricePerUnit: 100.0,
                    discountPricePerUnit: 0.0,
                    additionalDiscount: 0.0,
                    vatRateOption: ._7,
                    vatIncluded: true,
                    taxWithholdingRateOption: .none
                )
            ]
        }

        static func createLargePurchaseOrderGroup(
            user: User,
            supplier: Contact,
            customer: MyBusinese,
            product: Product
        ) -> [PurchaseOrder] {
            return (0..<40).map { index in
                let items = Self.createPurchaseOrderItems(product: product)
                return PurchaseOrder(
                    month: Int.random(in: 1...12),
                    year: Int.random(in: 2020...2025),
                    number: index + 1,
                    reference: "PO-\(index + 1)",
                    vatOption: .vatIncluded,
                    includedVat: true,
                    items: items,
                    additionalDiscountAmount: 0,
                    orderDate: Date(),
                    deliveryDate: Date().addingTimeInterval(86400),
                    paymentTermsDays: 30,
                    supplierId: supplier.id!,
                    customerId: customer.id!,
                    currency: .thb,
                    note: "Test Purchase Order \(index + 1)",
                    userId: UUID()
                )
            }
        }

        static var user: User {
            .init(
                id: UUID(),
                username: "testuser",
                passwordHash: "hashedPassword",
                personalInformation: .init(
                    fullname: "Name",
                    email: "abc@email.com",
                    phone: "",
                    address: "",
                    signSignature: nil),
                token: "token123",
                tokenExpried: Date().addingTimeInterval(3600))
        }

        static var supplier: Contact {
            .Stub.supplier
        }

        static var supplier2: Contact {
            .Stub.supplier2
        }

        static var customer: MyBusinese {
            .Stub.myCompany
        }
    }
}
