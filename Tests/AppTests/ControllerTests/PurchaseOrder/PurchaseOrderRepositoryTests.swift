//
//  PurchaseOrderRepositoryTests.swift
//  poc-swift-vapor-rest
//
//  Created by IntrodexMac on 19/9/2567 BE.
//

import Fluent
import FluentMongoDriver
import MockableTest
import Vapor
import XCTest

@testable import App

final class PurchaseOrderRepositoryTests: XCTestCase {

    var app: Application!
    var db: Database!

    private(set) var purchaseOrderRepository: PurchaseOrderRepository!
    private(set) var userRepository: UserRepository!
    private(set) var contactRepository: ContactRepository!
    private(set) var myBusineseRepository: MyBusineseRepository!
    private(set) var productRepository: ProductRepository!
    private(set) var serviceRepository: ServiceRepository!

    // Database configuration
    var dbHost: String!

    override func setUp() async throws {
        try await super.setUp()

        app = Application(.testing)
        dbHost = try dbHostURL(app)

        try configure(app,
                      dbHost: dbHost,
                      migration: PurchaseOrderMigration())

        db = app.db

        userRepository = UserRepository()
        contactRepository = ContactRepository()
        myBusineseRepository = MyBusineseRepository()
        productRepository = ProductRepository()
        serviceRepository = ServiceRepository()

        purchaseOrderRepository = PurchaseOrderRepository(
            productRepository: productRepository,
            serviceRepository: serviceRepository,
            myBusineseRepository: myBusineseRepository,
            contactRepository: contactRepository,
            userRepository: userRepository
        )

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

    // MARK: - Fetch All Tests

    func testFetchAll_WithValidData_ShouldReturnPurchaseOrders() async throws {
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

        let request = PurchaseOrderRequest.FetchAll(
            status: .all,
            page: 1,
            perPage: 20,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: .init(
                from: Date(),
                to: Date().addingTimeInterval(3600))
        )

        // When
        let result = try await purchaseOrderRepository.fetchAll(
            request: request,
            on: db)

        // Then
        XCTAssertEqual(result.items.count, 2)
    }

    func testFetchAll_WithPagination_ShouldReturnCorrectPurchaseOrders() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let pos = Stub.createLargePurchaseOrderGroup(
            user: user,
            supplier: contact,
            customer: customer,
            product: product)

        for po in pos {
            try await po.create(on: db)
        }

        let request = PurchaseOrderRequest.FetchAll(
            status: .all,
            page: 2,
            perPage: 25,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: .init(
                from: Date(),
                to: Date().addingTimeInterval(3600)
            )
        )

        // When
        let result = try await purchaseOrderRepository.fetchAll(request: request, on: db)

        // Then
        XCTAssertEqual(result.items.count, 15)
    }

    // MARK: - Fetch By ID Tests

    func testFetchById_ShouldReturnPurchaseOrder() async throws {
        //Given
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

        try await po1.create(on: db)

        // When
        let result = try await purchaseOrderRepository.fetchById(
            request: .init(id: po1.id!),
            on: db
        )

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, po1.id)
    }

    func testFetchById_NotFound_ShouldThrowError() async throws {
        // Given
        let invalidUUID = UUID()

        // When
        do {
            _ = try await purchaseOrderRepository.fetchById(request: .init(id: invalidUUID), on: db)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! DefaultError, DefaultError.notFound)
        }
    }

    // MARK: - Create Tests

    func testCreate_WithValidData_ShouldCreatePurchaseOrder() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        let items: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: product.id!,
                kind: .product,
                itemName: "Name",
                itemDescription: "Des",
                variantId: nil,
                qty: 1,
                pricePerUnit: 100,
                discountPricePerUnit: 0,
                vatRateOption: .none,
                vatIncluded: false,
                withholdingTaxRateOption: .none)
        ]

        let request = PurchaseOrderRequest.Create(
            reference: "PO-001",
            note: "Test purchase order",
            supplierId: contact.id!,
            customerId: business.id!,
            orderDate: Date(),
            deliveryDate: Date().addingTimeInterval(86400),
            paymentTermsDays: 30,
            items: items,
            additionalDiscountAmount: 0,
            vatOption: .vatIncluded,
            includedVat: true,
            currency: .thb
        )

        // When
        let result = try await purchaseOrderRepository.create(
            request: request,
            userId: .init(id: user.id!),
            on: db
        )

        // Then
        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.reference, "PO-001")
        XCTAssertEqual(result.note, "Test purchase order")
        XCTAssertEqual(result.$supplier.id, contact.id)
        XCTAssertEqual(result.$customer.id, business.id)
        XCTAssertEqual(
            result.orderDate.toDateString("yyyy-MM-dd"),
            request.orderDate.toDateString("yyyy-MM-dd"))
        XCTAssertEqual(
            result.deliveryDate.toDateString("yyyy-MM-dd"),
            request.deliveryDate.toDateString("yyyy-MM-dd"))
        XCTAssertEqual(result.paymentTermsDays, 30)
        XCTAssertEqual(result.items.count, 1)

        let firstItem = result.items.first!
        XCTAssertEqual(firstItem.itemName, "Name")
        XCTAssertEqual(firstItem.itemDescription, "Des")

        XCTAssertEqual(result.additionalDiscountAmount, 0)
        XCTAssertEqual(result.vatOption, .vatIncluded)
        XCTAssertEqual(result.includedVat, true)
        XCTAssertEqual(result.currency, .thb)
    }

    func testCreate_WithNotFoundSupplierId_ShouldThrowError() async throws {
        // Given
        let user = Stub.user
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        let items: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: product.id!,
                kind: .product,
                itemName: "Name",
                itemDescription: "Des",
                variantId: nil,
                qty: 1,
                pricePerUnit: 100,
                discountPricePerUnit: 0,
                vatRateOption: .none,
                vatIncluded: false,
                withholdingTaxRateOption: .none)
        ]

        let request = PurchaseOrderRequest.Create(
            reference: "PO-001",
            note: "Test purchase order",
            supplierId: .init(),
            customerId: business.id!,
            orderDate: Date(),
            deliveryDate: Date().addingTimeInterval(86400),
            paymentTermsDays: 30,
            items: items,
            additionalDiscountAmount: 0,
            vatOption: .vatIncluded,
            includedVat: true,
            currency: .thb
        )

        // When
        do {
            _ = try await purchaseOrderRepository.create(
                request: request,
                userId: .init(id: user.id!),
                on: db
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! PurchaseOrderRequest.Error, .notFoundSupplierId)
        }
    }

    func testCreate_WithNotFoundCustomerId_ShouldThrowError() async throws {
        // Given
        let user = Stub.user
        let contact = Stub.supplier
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await contact.create(on: db)
        try await product.create(on: db)

        let items: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: product.id!,
                kind: .product,
                itemName: "Name",
                itemDescription: "Des",
                variantId: nil,
                qty: 1,
                pricePerUnit: 100,
                discountPricePerUnit: 0,
                vatRateOption: .none,
                vatIncluded: false,
                withholdingTaxRateOption: .none)
        ]

        let request = PurchaseOrderRequest.Create(
            reference: "PO-001",
            note: "Test purchase order",
            supplierId: contact.id!,
            customerId: .init(),
            orderDate: Date(),
            deliveryDate: Date().addingTimeInterval(86400),
            paymentTermsDays: 30,
            items: items,
            additionalDiscountAmount: 0,
            vatOption: .vatIncluded,
            includedVat: true,
            currency: .thb
        )

        // When
        do {
            _ = try await purchaseOrderRepository.create(
                request: request,
                userId: .init(id: user.id!),
                on: db
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! PurchaseOrderRequest.Error, .notFoundCustomerId)
        }
    }

    // MARK: - Update Tests

    func testUpdate_WithValidData_ShouldUpdatePurchaseOrder() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        // create po
        let po1 = Stub.createPo(
            user: user,
            supplier: supplier,
            customer: business,
            product: product)

        try await po1.create(on: db)

        // prepare update
        let updatedSupplier = Stub.supplier2
        try await updatedSupplier.create(on: db)

        let updateDeliveryDate = po1.deliveryDate.addingTimeInterval(604800)  // add 7 days
        let updateOrderDate = po1.orderDate.addingTimeInterval(86400)  // add 1 day

        let updateRequest = PurchaseOrderRequest.Update(
            reference: "Updated PO-001",
            note: "Updated note",
            paymentTermsDays: 61,
            supplierId: updatedSupplier.id,
            deliveryDate: updateDeliveryDate,
            vatOption: .vatExcluded,
            orderDate: updateOrderDate,
            additionalDiscountAmount: 0,
            currency: .thb,
            includedVat: true
        )

        // When
        let result = try await purchaseOrderRepository.update(
            byId: .init(id: po1.id!),
            request: updateRequest,
            userId: .init(id: user.id!),
            on: db
        )

        // Then
        XCTAssertEqual(result.reference, "Updated PO-001")
        XCTAssertEqual(result.note, "Updated note")
        XCTAssertEqual(result.paymentTermsDays, 61)
        XCTAssertEqual(result.$supplier.id, updatedSupplier.id)
        XCTAssertEqual(
            result.deliveryDate.toDateString("yyyy-MM-dd"),
            updateDeliveryDate.toDateString("yyyy-MM-dd"))
        XCTAssertEqual(
            result.orderDate.toDateString("yyyy-MM-dd"),
            updateOrderDate.toDateString("yyyy-MM-dd"))
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.additionalDiscountAmount, 0)
        XCTAssertEqual(result.vatOption, .vatExcluded)
        XCTAssertEqual(result.includedVat, true)
        XCTAssertEqual(result.currency, .thb)
    }

    func testUpdate_WithInvalidSupplier_ShouldThrowError() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        // create po
        let po1 = Stub.createPo(
            user: user,
            supplier: supplier,
            customer: business,
            product: product)

        try await po1.create(on: db)

        // prepare update
        let updatedSupplierId = UUID()

        let updateDeliveryDate = po1.deliveryDate.addingTimeInterval(604800)  // add 7 days
        let updateOrderDate = po1.orderDate.addingTimeInterval(86400)  // add 1 day

        let updateRequest = PurchaseOrderRequest.Update(
            reference: "Updated PO-001",
            note: "Updated note",
            paymentTermsDays: 61,
            supplierId: updatedSupplierId,
            deliveryDate: updateDeliveryDate,
            vatOption: .vatExcluded,
            orderDate: updateOrderDate,
            additionalDiscountAmount: 0,
            currency: .thb,
            includedVat: true
        )

        // When
        do {
            _ = try await purchaseOrderRepository.update(
                byId: .init(id: po1.id!),
                request: updateRequest,
                userId: .init(id: user.id!),
                on: db
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as! PurchaseOrderRequest.Error, .notFoundSupplierId)
        }
    }

    // MARK: - Search Tests

    func testSearch_WithValidQuery_ShouldReturnMatchingPurchaseOrders() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        // create po
        let po1 = Stub.createPo(
            user: user,
            supplier: supplier,
            customer: business,
            product: product)

        try await po1.create(on: db)

        let searchRequest = PurchaseOrderRequest.Search(
            query: "PO-001",
            page: 1,
            perPage: 10,
            status: .all,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: .init(
                from: Date().addingTimeInterval(-3600),
                to: Date().addingTimeInterval(3600))
        )

        // When
        let result = try await purchaseOrderRepository.search(request: searchRequest, on: db)

        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.reference, po1.reference)
    }

    func testSearch_WithInvalidQuery_ShouldReturnEmptyResult() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        // create po
        let po1 = Stub.createPo(
            user: user,
            supplier: supplier,
            customer: business,
            product: product)

        try await po1.create(on: db)

        let searchRequest = PurchaseOrderRequest.Search(
            query: "AAAAAAA",
            page: 1,
            perPage: 10,
            status: .all,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: .init(
                from: Date().addingTimeInterval(-3600),
                to: Date().addingTimeInterval(3600))
        )

        // When
        let result = try await purchaseOrderRepository.search(
            request: searchRequest,
            on: db)

        // Then
        XCTAssertEqual(result.items.count, 0)
    }

    func testSearch_WithStatusPending_ShouldReturnMatchingPurchaseOrders() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let contact = Stub.supplier
        let business = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await contact.create(on: db)
        try await business.create(on: db)
        try await product.create(on: db)

        // create po
        let po1 = Stub.createPo(
            user: user,
            supplier: supplier,
            customer: business,
            product: product)
        po1.status = .pending

        try await po1.create(on: db)

        let searchRequest = PurchaseOrderRequest.Search(
            query: "PO-001",
            page: 1,
            perPage: 10,
            status: .pending,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: .init(
                from: Date().addingTimeInterval(-3600),
                to: Date().addingTimeInterval(3600))
        )

        // When
        let result = try await purchaseOrderRepository.search(
            request: searchRequest,
            on: db)

        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.reference, po1.reference)
    }

    // MARK: - Replace Items Tests

    func testReplaceItems_WithValidData_ShouldReplaceItems() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")
        let newProduct = Product(name: "Product B")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)
        try await newProduct.create(on: db)

        let po = Stub.createPo(user: user, supplier: supplier, customer: customer, product: product)
        try await po.create(on: db)

        /*
         struct CreateItem: Content, Validatable {
             let itemId: UUID
             let kind: PurchaseOrderItem.Kind
             let itemName: String
             let itemDescription: String
             let variantId: UUID?
             let qty: Double
             let pricePerUnit: Double
             let discountPricePerUnit: Double
             let vatRateOption: VatRateOption
             let vatIncluded: Bool
             let withholdingTaxRateOption: TaxWithholdingRateOption

             init(itemId: UUID,
                  kind: PurchaseOrderItem.Kind,
                  itemName: String,
                  itemDescription: String,
                  variantId: UUID?,
                  qty: Double,
                  pricePerUnit: Double,
                  discountPricePerUnit: Double,
                  vatRateOption: VatRateOption,
                  vatIncluded: Bool,
                  withholdingTaxRateOption: TaxWithholdingRateOption) {
                 self.itemId = itemId
                 self.kind = kind
                 self.itemName = itemName
                 self.itemDescription = itemDescription
                 self.variantId = variantId
                 self.qty = qty
                 self.pricePerUnit = pricePerUnit
                 self.discountPricePerUnit = discountPricePerUnit
                 self.vatRateOption = vatRateOption
                 self.vatIncluded = vatIncluded
                 self.withholdingTaxRateOption = withholdingTaxRateOption
             }
         */
        let newItems: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: newProduct.id!,
                kind: .product,
                itemName: "Product B",
                itemDescription: "Description of Product B",
                variantId: nil,
                qty: 2,
                pricePerUnit: 150.0,
                discountPricePerUnit: 0,
                vatRateOption: ._7,
                vatIncluded: true,
                withholdingTaxRateOption: .none
            )
        ]

        let request = PurchaseOrderRequest.ReplaceItems(items: newItems,
                                                        vatOption: .vatIncluded,
                                                        additionalDiscountAmount: 50,
                                                        includedVat: true)

        // When
        let result = try await purchaseOrderRepository.replaceItems(id: .init(id: po.id!),
                                                                    request: request,
                                                                    userId: .init(id: user.id!),
                                                                    on: db)

        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.itemName, "Product B")
    }

    // MARK: - Items Reorder Tests

    func testItemsReorder_WithValidData_ShouldReorderItems() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")
        let newProduct = Product(name: "Product B")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)
        try await newProduct.create(on: db)

        let po = Stub.createPo(user: user, supplier: supplier, customer: customer, product: product)
        try await po.create(on: db)

        let newItems: [PurchaseOrderRequest.CreateItem] = [
            .init(
                itemId: newProduct.id!,
                kind: .product,
                itemName: "Product B",
                itemDescription: "Description B",
                variantId: nil,
                qty: 2,
                pricePerUnit: 200,
                discountPricePerUnit: 0,
                vatRateOption: .none,
                vatIncluded: false,
                withholdingTaxRateOption: .none
            )
        ]

        let replaceRequest = PurchaseOrderRequest.ReplaceItems(
            items: newItems,
            vatOption: .vatIncluded,
            additionalDiscountAmount: 0,
            includedVat: true
        )
        let replacedPo = try await purchaseOrderRepository.replaceItems(
            id: .init(id: po.id!),
            request: replaceRequest,
            userId: .init(id: user.id!),
            on: db
        )

        let itemsOrder = replacedPo.items.map { GeneralRequest.FetchById(id: $0.id!) }

        // When
        let result = try await purchaseOrderRepository.itemsReorder(
            id: .init(id: po.id!),
            itemsOrder: itemsOrder,
            userId: .init(id: user.id!),
            on: db
        )

        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.itemName, "Product B")
    }

    // MARK: - Approve Tests

    func testApprove_WithValidData_ShouldApprovePurchaseOrder() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(user: user, supplier: supplier, customer: customer, product: product)
        po.status = .pending
        try await po.create(on: db)

        // When
        let result = try await purchaseOrderRepository.approve(id: .init(id: po.id!), userId: .init(id: user.id!), on: db)

        // Then
        XCTAssertEqual(result.status, .approved)
    }

    // MARK: - Void Tests

    func testVoid_WithValidData_ShouldVoidPurchaseOrder() async throws {
        // Given
        let user = Stub.user
        let supplier = Stub.supplier
        let customer = Stub.customer
        let product = Product(name: "Product A")

        try await user.create(on: db)
        try await supplier.create(on: db)
        try await customer.create(on: db)
        try await product.create(on: db)

        let po = Stub.createPo(user: user, supplier: supplier, customer: customer, product: product)
        po.status = .approved
        try await po.create(on: db)

        // When
        let result = try await purchaseOrderRepository.void(id: .init(id: po.id!),
                                                            userId: .init(id: user.id!),
                                                            on: db)

        // Then
        XCTAssertEqual(result.status, .voided)
    }
}

// MARK: - Stub Data

extension PurchaseOrderRepositoryTests {
    fileprivate struct Stub {

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
                    itemDescription: product.descriptionInfo ?? "",
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
                username: "ABC",
                passwordHash: "12345",
                personalInformation: .init(
                    fullname: "Name",
                    email: "abc@email.com",
                    phone: "",
                    address: "",
                    signSignature: nil))
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
