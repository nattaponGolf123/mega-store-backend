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
        try await dropCollection(db, schema: Product.schema)
        try await dropCollection(db, schema: Service.schema)
        try await dropCollection(db, schema: Contact.schema)
        try await dropCollection(db, schema: MyBusinese.schema)
        
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
        
        try app.test(.PUT, "purchase_orders/\(po.id!)",
                     beforeRequest: { req in
            
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, "PO-12345")
            XCTAssertEqual(response.note, "Sample note")
            XCTAssertEqual(response.paymentTermsDays, 15)
            XCTAssertEqual(response.supplier?.id, contact2.id)
            XCTAssertEqual(response.deliveryDate.toDateString("yyyy-MM-dd"), updateDate.toDateString("yyyy-MM-dd"))
            XCTAssertEqual(response.vatOption, .vatExcluded)
            XCTAssertEqual(response.orderDate.toDateString("yyyy-MM-dd"), updateDate.toDateString("yyyy-MM-dd"))
            XCTAssertEqual(response.additionalDiscountAmount, 10)
            XCTAssertEqual(response.includedVat, true)
        }
    }
    
    // MARK: - Test POST /purchase_orders/:id/approve
    func testApprove_WithInvalidOrder_ShouldReturnBadRequest() async throws {
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)

        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)
        
        given(generalValidator).validateID(.any).willReturn(request)
        given(repo).approve(id: .matching({ $0.id == id }), userId: .any, on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.POST, "purchase_orders/\(id.uuidString)/approve") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testApprove_WithValidOrder_ShouldReturnOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        try await po.create(on: db)

        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)
        given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po.id!))

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.POST, "purchase_orders/\(po.id!.uuidString)/approve") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, po.reference)
        }
    }
   
    // MARK: - Test GET /purchase_orders/search
    func testSearch_WithInvalidQuery_ShouldReturnBadRequest() async throws {
        // Given
        let now = Date()
        let nextDay = now.addingTimeInterval(86400)
        let searchQuery = PurchaseOrderRequest.Search(query: "",
                                                      periodDate: .init(from: now,
                                                                        to: nextDay))
        given(validator).validateSearchQuery(.any).willReturn(searchQuery)
        given(repo).search(request: .any,
                           on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.GET, "purchase_orders/search?query=") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testSearch_WithValidQuery_ShouldReturnOrders() async throws {
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

        let ytd = Date().addingTimeInterval(-86400)
        let nextDay = Date().addingTimeInterval(86400)
        let searchQuery = PurchaseOrderRequest.Search(query: "PO",
                                                      periodDate: .init(from: ytd,
                                                                        to: nextDay))
        
        given(validator).validateSearchQuery(.any).willReturn(searchQuery)
        
        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.GET, "purchase_orders/search?query=PO") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PaginatedResponse<PurchaseOrderResponse>.self)
            XCTAssertEqual(response.items.count, 2)
        }
    }

    // MARK: - Test POST /purchase_orders/:id/void
    func testVoid_WithInvalidOrder_ShouldReturnBadRequest() async throws {
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)

        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)
        
        given(generalValidator).validateID(.any).willReturn(request)
        given(repo).void(id: .matching({ $0.id == id }), userId: .any, on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.POST, "purchase_orders/\(id.uuidString)/void") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testVoid_WithValidOrder_ShouldReturnOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        try await po.create(on: db)

        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)
        
        given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po.id!))

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.POST, "purchase_orders/\(po.id!.uuidString)/void") { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, po.reference)
        }
    }

    // MARK: - Test PUT /purchase_orders/:id/replace_items
    func testReplaceItems_WithInvalidOrder_ShouldReturnBadRequest() async throws {
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        let replaceItemsRequest = PurchaseOrderRequest.ReplaceItems(
            items: [],
            vatOption: .vatIncluded,
            additionalDiscountAmount: 0,
            includedVat: true
        )
        
        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        given(generalValidator).validateID(.any).willReturn(request)
        given(validator).validateReplaceItems(.any).willReturn((request, replaceItemsRequest))
        given(repo).replaceItems(id: .matching({ $0.id == id }), request: .any, userId: .any, on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "purchase_orders/\(id.uuidString)/replace_items") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testReplaceItems_WithValidOrder_ShouldReturnOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        try await po.create(on: db)

        let replaceItemsRequest = PurchaseOrderRequest.ReplaceItems(
            items: [PurchaseOrderRequest.CreateItem(
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
                withholdingTaxRateOption: .none
            )],
            vatOption: .vatIncluded,
            additionalDiscountAmount: 0,
            includedVat: true
        )
        
        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po.id!))
        given(validator).validateReplaceItems(.any).willReturn((GeneralRequest.FetchById(id: po.id!), replaceItemsRequest))

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.PUT, "purchase_orders/\(po.id!.uuidString)/replace_items",
                     beforeRequest: { req in
            try req.content.encode(replaceItemsRequest)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, po.reference)
        }
    }

    // MARK: - Test PUT /purchase_orders/:id/reorder_items
    func testReorderItems_WithInvalidOrder_ShouldReturnBadRequest() async throws {
        // Given
        let id = UUID()
        let request = GeneralRequest.FetchById(id: id)
        let reorderItemsRequest = PurchaseOrderRequest.ReorderItems(itemIdOrder: [])
        
        let jwtPayload = UserJWTPayload(user: Stub.user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)

        given(generalValidator).validateID(.any).willReturn(request)
        given(validator).validateReorderItems(.any).willReturn((request, reorderItemsRequest))
        given(repo).itemsReorder(id: .matching({ $0.id == id }), itemsOrder: .any, userId: .any, on: .any).willThrow(DefaultError.invalidInput)

        try app.test(.PUT, "purchase_orders/\(id.uuidString)/reorder_items") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testReorderItems_WithValidOrder_ShouldReturnOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(
            user: user,
            supplier: contact,
            customer: customer,
            product: product
        )
        try await po.create(on: db)

        let jwtPayload = UserJWTPayload(user: user)
        given(jwtValidator).validateToken(.any).willReturn(jwtPayload)
        
        given(generalValidator).validateID(.any).willReturn(GeneralRequest.FetchById(id: po.id!))
        
        let id = GeneralRequest.FetchById(id: po.id!)
        let reorderItemsRequest = PurchaseOrderRequest.ReorderItems(itemIdOrder: [po.items.first!.id!])
        given(validator).validateReorderItems(.any).willReturn((id, reorderItemsRequest))

        controller = .init(
            repository: PurchaseOrderRepository(),
            validator: validator,
            generalValidator: generalValidator,
            jwtValidator: jwtValidator)

        try app.register(collection: controller)

        try app.test(.PUT, "purchase_orders/\(po.id!.uuidString)/reorder_items",
                     beforeRequest: { req in
            //try req.content.encode(reorderItemsRequest)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let response = try res.content.decode(PurchaseOrderResponse.self)
            XCTAssertEqual(response.reference, po.reference)
        }
    }

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
