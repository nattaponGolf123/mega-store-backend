//
//  Test.swift
//  poc-swift-vapor-rest
//
//  Created by IntrodexMac on 19/9/2567 BE.
//

import XCTest
import Vapor
@testable import App

final class PurchaseOrderRequestTests: XCTestCase {
    
    // MARK: - Create Tests
    
    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        let supplierId = UUID()
        let customerId = UUID()
        let itemId = UUID()
        let orderDate = Date()
        let deliveryDate = Date()

        let item = PurchaseOrderRequest.CreateItem(
            itemId: itemId,
            kind: .product,
            itemName: "Product 1",
            itemDescription: "Product 1 Description",
            variantId: nil,
            qty: 10.0,
            pricePerUnit: 100.0,
            discountPricePerUnit: 10.0,
            vatRateOption: ._7,
            vatIncluded: true,
            withholdingTaxRateOption: ._3
        )

        let create = PurchaseOrderRequest.Create(
            reference: "PO-12345",
            note: "Test Purchase Order",
            supplierId: supplierId,
            customerId: customerId,
            orderDate: orderDate,
            deliveryDate: deliveryDate,
            paymentTermsDays: 30,
            items: [item],
            additionalDiscountAmount: 0.0,
            vatOption: .vatExcluded,
            includedVat: true,
            currency: .thb
        )

        XCTAssertEqual(create.reference, "PO-12345")
        XCTAssertEqual(create.note, "Test Purchase Order")
        XCTAssertEqual(create.supplierId, supplierId)
        XCTAssertEqual(create.customerId, customerId)
        XCTAssertEqual(create.items.count, 1)
        XCTAssertEqual(create.items.first?.itemName, "Product 1")
        XCTAssertEqual(create.items.first?.itemDescription, "Product 1 Description")
        XCTAssertEqual(create.items.first?.pricePerUnit, 100.0)
        XCTAssertEqual(create.vatOption, .vatExcluded)
        XCTAssertEqual(create.includedVat, true)
    }

    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let supplierId = UUID()
        let customerId = UUID()
        let itemId = UUID()
        let orderDate = Date()
        let deliveryDate = Date()

        let item = PurchaseOrderRequest.CreateItem(
            itemId: itemId,
            kind: .product,
            itemName: "Product 1",
            itemDescription: "Product 1 Description",
            variantId: nil,
            qty: 10.0,
            pricePerUnit: 100.0,
            discountPricePerUnit: 10.0,
            vatRateOption: ._7,
            vatIncluded: true,
            withholdingTaxRateOption: ._3
        )

        let create = PurchaseOrderRequest.Create(
            reference: "PO-12345",
            note: "Test Purchase Order",
            supplierId: supplierId,
            customerId: customerId,
            orderDate: orderDate,
            deliveryDate: deliveryDate,
            paymentTermsDays: 30,
            items: [item],
            additionalDiscountAmount: 0.0,
            vatOption: .vatExcluded,
            includedVat: true,
            currency: .thb
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(create)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["reference"] as? String, "PO-12345")
        XCTAssertEqual(jsonObject?["note"] as? String, "Test Purchase Order")
        XCTAssertEqual(jsonObject?["supplier_id"] as? String, supplierId.uuidString)
        XCTAssertEqual(jsonObject?["customer_id"] as? String, customerId.uuidString)
        
        let firstItem = (jsonObject?["items"] as? [[String: Any]])?.first
        XCTAssertEqual(firstItem?["item_id"] as? String, itemId.uuidString)
        XCTAssertEqual(firstItem?["kind"] as? String, "PRODUCT")
        XCTAssertEqual(firstItem?["item_name"] as? String, "Product 1")
        XCTAssertEqual(firstItem?["item_description"] as? String, "Product 1 Description")
        XCTAssertEqual(firstItem?["qty"] as? Double, 10.0)
        XCTAssertEqual(firstItem?["price_per_unit"] as? Double, 100.0)
        XCTAssertEqual(firstItem?["discount_price_per_unit"] as? Double, 10.0)
        XCTAssertEqual(firstItem?["vat_rate_option"] as? String, "VAT7")
        XCTAssertEqual(firstItem?["vat_included"] as? Bool, true)
        XCTAssertEqual(firstItem?["withholding_tax_rate_option"] as? String, "TAX3")
        
        XCTAssertEqual(jsonObject?["vat_option"] as? String, "VAT_EXCLUDED")
        XCTAssertEqual(jsonObject?["included_vat"] as? Bool, true)
    }

    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let supplierId = UUID()
        let customerId = UUID()
        let itemId = UUID()

        let json = """
        {
            "reference": "PO-12345",
            "note": "Test Purchase Order",
            "supplier_id": "\(supplierId.uuidString)",
            "customer_id": "\(customerId.uuidString)",
            "delivery_date": "2024-06-25",
            "order_date": "2024-06-25",
            "payment_terms_days": 30,
            "items": [{
                "item_id": "\(itemId.uuidString)",
                "kind": "PRODUCT",
                "item_name": "Product 1",
                "item_description": "Product 1 Description",
                "qty": 10.0,
                "price_per_unit": 100.0,
                "discount_price_per_unit": 10.0,
                "vat_rate_option": "VAT7",
                "vat_included": true,
                "withholding_tax_rate_option": "TAX3"
            }],
            "vat_option": "VAT_INCLUDED",
            "included_vat": true,
            "currency": "THB",
            "additional_discount_amount": 0.0
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let create = try decoder.decode(PurchaseOrderRequest.Create.self, from: data)

        XCTAssertEqual(create.reference, "PO-12345")
        XCTAssertEqual(create.note, "Test Purchase Order")
        XCTAssertEqual(create.supplierId, supplierId)
        XCTAssertEqual(create.customerId, customerId)
        XCTAssertEqual(create.items.count, 1)
        XCTAssertEqual(create.items.first?.itemName, "Product 1")
        XCTAssertEqual(create.items.first?.pricePerUnit, 100.0)
        XCTAssertEqual(create.vatOption, .vatIncluded)
        XCTAssertEqual(create.includedVat, true)
    }
    
    func testYearNumber() throws {
        let supplierId = UUID()
        let customerId = UUID()
        let itemId = UUID()

        let json = """
        {
            "reference": "PO-12345",
            "note": "Test Purchase Order",
            "supplier_id": "\(supplierId.uuidString)",
            "customer_id": "\(customerId.uuidString)",
            "delivery_date": "2024-06-25",
            "order_date": "2024-06-25",
            "payment_terms_days": 30,
            "items": [{
                "item_id": "\(itemId.uuidString)",
                "kind": "PRODUCT",
                "item_name": "Product 1",
                "item_description": "Product 1 Description",
                "qty": 10.0,
                "price_per_unit": 100.0,
                "discount_price_per_unit": 10.0,
                "vat_rate_option": "VAT7",
                "vat_included": true,
                "withholding_tax_rate_option": "TAX3"
            }],
            "vat_option": "VAT_INCLUDED",
            "included_vat": true,
            "currency": "THB",
            "additional_discount_amount": 0.0
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let create = try decoder.decode(PurchaseOrderRequest.Create.self, from: data)

        let year = create.yearNumber()
        XCTAssertEqual(year, 2024)
    }
    
    func testMonthNumber() throws {
        let supplierId = UUID()
        let customerId = UUID()
        let itemId = UUID()

        let json = """
        {
            "reference": "PO-12345",
            "note": "Test Purchase Order",
            "supplier_id": "\(supplierId.uuidString)",
            "customer_id": "\(customerId.uuidString)",
            "delivery_date": "2024-06-25",
            "order_date": "2024-06-25",
            "payment_terms_days": 30,
            "items": [{
                "item_id": "\(itemId.uuidString)",
                "kind": "PRODUCT",
                "item_name": "Product 1",
                "item_description": "Product 1 Description",
                "qty": 10.0,
                "price_per_unit": 100.0,
                "discount_price_per_unit": 10.0,
                "vat_rate_option": "VAT7",
                "vat_included": true,
                "withholding_tax_rate_option": "TAX3"
            }],
            "vat_option": "VAT_INCLUDED",
            "included_vat": true,
            "currency": "THB",
            "additional_discount_amount": 0.0
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let create = try decoder.decode(PurchaseOrderRequest.Create.self, from: data)

        let year = create.monthNumber()
        XCTAssertEqual(year, 6)
    }

    // MARK: - FetchAll Tests
    
    func testFetchAllInit_WithValidValues_ShouldReturnCorrectValues() {
        let periodDate = PeriodDate(from: Date(), to: Date())
        let fetchAll = PurchaseOrderRequest.FetchAll(
            status: .pending,
            page: 1,
            perPage: 100,
            sortBy: .createdAt,
            sortOrder: .desc,
            periodDate: periodDate
        )
        
        XCTAssertEqual(fetchAll.status, .pending)
        XCTAssertEqual(fetchAll.page, 1)
        XCTAssertEqual(fetchAll.perPage, 100)
        XCTAssertEqual(fetchAll.sortBy, .createdAt)
        XCTAssertEqual(fetchAll.sortOrder, .desc)
        XCTAssertEqual(fetchAll.periodDate.from, periodDate.from)
        XCTAssertEqual(fetchAll.periodDate.to, periodDate.to)
    }
    
    func testFetchAllEncode_WithValidInstance_ShouldReturnJSON() throws {
        let periodDate = PeriodDate(from: Date(), to: Date())
        let fetchAll = PurchaseOrderRequest.FetchAll(
            status: .pending,
            page: 1,
            perPage: 100,
            sortBy: .createdAt,
            sortOrder: .desc,
            periodDate: periodDate
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(fetchAll)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["status"] as? String, "PENDING")
        XCTAssertEqual(jsonObject?["page"] as? Int, 1)
        XCTAssertEqual(jsonObject?["per_page"] as? Int, 100)
        XCTAssertEqual(jsonObject?["sort_by"] as? String, "CREATED_AT")
        XCTAssertEqual(jsonObject?["sort_order"] as? String, "DESC")
    }
    
    func testFetchAllDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "status": "PENDING",
            "page": 1,
            "per_page": 100,
            "sort_by": "CREATED_AT",
            "sort_order": "DESC",            
            "from": "2024-06-25",
            "to": "2024-06-25"            
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let fetchAll = try decoder.decode(PurchaseOrderRequest.FetchAll.self, from: data)
        
        XCTAssertEqual(fetchAll.status, .pending)
        XCTAssertEqual(fetchAll.page, 1)
        XCTAssertEqual(fetchAll.perPage, 100)
        XCTAssertEqual(fetchAll.sortBy, .createdAt)
        XCTAssertEqual(fetchAll.sortOrder, .desc)
        XCTAssertEqual(fetchAll.periodDate.from.toDateString("yyyy-MM-dd"), "2024-06-25")
        XCTAssertEqual(fetchAll.periodDate.to.toDateString("yyyy-MM-dd"), "2024-06-25")
    }

    // MARK: - Search Tests
    
    func testSearchInit_WithValidValues_ShouldReturnCorrectValues() {
        let periodDate = PeriodDate(from: Date(), to: Date())
        let search = PurchaseOrderRequest.Search(
            query: "Test Query",
            page: 1,
            perPage: 100,
            status: .approved,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: periodDate
        )
        
        XCTAssertEqual(search.query, "Test Query")
        XCTAssertEqual(search.page, 1)
        XCTAssertEqual(search.perPage, 100)
        XCTAssertEqual(search.status, .approved)
        XCTAssertEqual(search.sortBy, .createdAt)
        XCTAssertEqual(search.sortOrder, .asc)
        XCTAssertEqual(search.periodDate.from, periodDate.from)
        XCTAssertEqual(search.periodDate.to, periodDate.to)
    }

    func testSearchEncode_WithValidInstance_ShouldReturnJSON() throws {
        let periodDate = PeriodDate(from: Date(), to: Date())
        let search = PurchaseOrderRequest.Search(
            query: "Test Query",
            page: 1,
            perPage: 100,
            status: .approved,
            sortBy: .createdAt,
            sortOrder: .asc,
            periodDate: periodDate
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(search)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["q"] as? String, "Test Query")
        XCTAssertEqual(jsonObject?["page"] as? Int, 1)
        XCTAssertEqual(jsonObject?["per_page"] as? Int, 100)
        XCTAssertEqual(jsonObject?["sort_by"] as? String, "CREATED_AT")
        XCTAssertEqual(jsonObject?["sort_order"] as? String, "ASC")
        XCTAssertEqual(jsonObject?["status"] as? String, "APPROVED")
    }

    // MARK: - CreateItem Tests
    
    func testCreateItemInit_WithValidValues_ShouldReturnCorrectValues() {
        let itemId = UUID()
        let createItem = PurchaseOrderRequest.CreateItem(
            itemId: itemId,
            kind: .product,
            itemName: "Test Product",
            itemDescription: "Product Description",
            variantId: nil,
            qty: 5.0,
            pricePerUnit: 50.0,
            discountPricePerUnit: 5.0,
            vatRateOption: ._7,
            vatIncluded: true,
            withholdingTaxRateOption: ._3
        )
        
        XCTAssertEqual(createItem.itemId, itemId)
        XCTAssertEqual(createItem.kind, .product)
        XCTAssertEqual(createItem.itemName, "Test Product")
        XCTAssertEqual(createItem.itemDescription, "Product Description")
        XCTAssertEqual(createItem.qty, 5.0)
        XCTAssertEqual(createItem.pricePerUnit, 50.0)
        XCTAssertEqual(createItem.discountPricePerUnit, 5.0)
        XCTAssertEqual(createItem.vatRateOption, ._7)
        XCTAssertEqual(createItem.vatIncluded, true)
        XCTAssertEqual(createItem.withholdingTaxRateOption, ._3)
    }

    // MARK: - UpdateItem Tests
    
    func testUpdateItemInit_WithValidValues_ShouldReturnCorrectValues() {
        let id = UUID()
        let itemId = UUID()
        let updateItem = PurchaseOrderRequest.UpdateItem(
            id: id,
            itemId: itemId,
            kind: .service,
            itemName: "Test Service",
            itemDescription: "Service Description",
            variantId: nil,
            qty: 2.0,
            pricePerUnit: 100.0,
            discountPricePerUnit: 10.0,
            vatRateOption: ._7,
            vatIncluded: false,
            withholdingTaxRateOption: .none
        )
        
        XCTAssertEqual(updateItem.id, id)
        XCTAssertEqual(updateItem.itemId, itemId)
        XCTAssertEqual(updateItem.kind, .service)
        XCTAssertEqual(updateItem.itemName, "Test Service")
        XCTAssertEqual(updateItem.itemDescription, "Service Description")
        XCTAssertEqual(updateItem.qty, 2.0)
        XCTAssertEqual(updateItem.pricePerUnit, 100.0)
        XCTAssertEqual(updateItem.discountPricePerUnit, 10.0)
        XCTAssertEqual(updateItem.vatRateOption, ._7)
        XCTAssertEqual(updateItem.vatIncluded, false)
        XCTAssertEqual(updateItem.withholdingTaxRateOption, .none)
    }

    // MARK: - Update Tests
    
    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let supplierId = UUID()
        let orderDate = Date()
        let update = PurchaseOrderRequest.Update(
            reference: "Updated Reference",
            note: "Updated Note",
            paymentTermsDays: 60,
            supplierId: supplierId,
            deliveryDate: orderDate,
            vatOption: .vatIncluded,
            orderDate: orderDate,
            additionalDiscountAmount: 100.0,
            currency: .thb,
            includedVat: true
        )
        
        XCTAssertEqual(update.reference, "Updated Reference")
        XCTAssertEqual(update.note, "Updated Note")
        XCTAssertEqual(update.paymentTermsDays, 60)
        XCTAssertEqual(update.supplierId, supplierId)
        XCTAssertEqual(update.deliveryDate, orderDate)
        XCTAssertEqual(update.vatOption, .vatIncluded)
        XCTAssertEqual(update.orderDate, orderDate)
        XCTAssertEqual(update.additionalDiscountAmount, 100.0)
        XCTAssertEqual(update.currency, .thb)
        XCTAssertEqual(update.includedVat, true)
    }

    // MARK: - ReplaceItems Tests
    /*
     struct ReplaceItems: Content, Validatable {
         let items: [UpdateItem]
         let vatOption: PurchaseOrder.VatOption
         let additionalDiscountAmount: Double
         let includedVat: Bool
         
         init(items: [UpdateItem],
              vatOption: PurchaseOrder.VatOption,
              additionalDiscountAmount: Double,
              includedVat: Bool) {
             self.items = items
             self.vatOption = vatOption
             self.additionalDiscountAmount = additionalDiscountAmount
             self.includedVat = includedVat
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.items = try container.decode([UpdateItem].self, forKey: .items)
             self.vatOption = try container.decode(PurchaseOrder.VatOption.self, forKey: .vatOption)
             self.additionalDiscountAmount = try container.decode(Double.self, forKey: .additionalDiscountAmount)
             self.includedVat = try container.decode(Bool.self, forKey: .includedVat)
         }
         
         func poItems() -> [PurchaseOrderItem] {
             //additionalDiscountPerItem is zero if nil
             //var additionalDiscountPerItem: Double = 0
             //if let additionalDiscountAmount {
             let additionalDiscountPerItem = additionalDiscountAmount / Double(items.count)
             //}
             
             let poItems: [PurchaseOrderItem] = items.map({
                 .init(id: $0.id,
                       itemId: $0.itemId,
                       kind: $0.kind,
                       itemName: $0.name,
                       itemDescription: $0.description,
                       variantId: $0.variantId,
                       qty: $0.qty,
                       pricePerUnit: $0.pricePerUnit,
                       discountPricePerUnit: $0.discountPricePerUnit,
                       additionalDiscount: 0,//additionalDiscountPerItem,
                       vatRateOption: $0.vatRateOption.vatRate,
                       vatIncluded: $0.vatIncluded,
                       taxWithholdingRate: $0.withholdingTaxRateOption.taxRate)
             })
             
             return poItems
         }
         
         enum CodingKeys: String, CodingKey {
             case items
             case vatOption = "vat_option"
             case additionalDiscountAmount = "additional_discount_amount"
             case includedVat = "included_vat"
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("vat_option", as: PurchaseOrder.VatOption.self, required: true)
             validations.add("additional_discount_amount", as: Double.self, is: .range(0...), required: true)
             validations.add("included_vat", as: Bool.self, required: true)
             validations.add("items", as: [CreateItem].self, is: !.empty, required: true)
         }
                 
     }
     */
    func testReplaceItemsInit_WithValidValues_ShouldReturnCorrectValues() {
        let items = [
            PurchaseOrderRequest.CreateItem(
                itemId: UUID(),
                kind: .service,
                itemName: "Test Service",
                itemDescription: "Service Description",
                variantId: nil,
                qty: 2.0,
                pricePerUnit: 100.0,
                discountPricePerUnit: 10.0,
                vatRateOption: ._7,
                vatIncluded: false,
                withholdingTaxRateOption: .none
            )
        ]
        let replaceItems = PurchaseOrderRequest.ReplaceItems(
            items: items,
            vatOption: .vatIncluded,
            additionalDiscountAmount: 100.0,
            includedVat: true
        )
        
        XCTAssertEqual(replaceItems.items.count, 1)
        XCTAssertEqual(replaceItems.vatOption, .vatIncluded)
        XCTAssertEqual(replaceItems.additionalDiscountAmount, 100.0)
        XCTAssertEqual(replaceItems.includedVat, true)
    }
    
    func testReplaceItemsDecode_WithValidValues_ShouldReturnCorrectValues() {
        let json = """
        {
            "items": [
                {
                    "item_id": "00000000-0000-0000-0000-000000000000",
                    "kind": "SERVICE",
                    "item_name": "Test Service",
                    "item_description": "Service Description",
                    "qty": 2.0,
                    "price_per_unit": 100.0,
                    "discount_price_per_unit": 10.0,
                    "vat_rate_option": "VAT7",
                    "vat_included": false,
                    "withholding_tax_rate_option": "NONE"
                }
            ],
            "vat_option": "VAT_INCLUDED",
            "additional_discount_amount": 100.0,
            "included_vat": true
        }
        """.data(using: .utf8)!
        
        let replaceItems = try! JSONDecoder().decode(PurchaseOrderRequest.ReplaceItems.self, from: json)
        
        XCTAssertEqual(replaceItems.items.count, 1)
        XCTAssertEqual(replaceItems.vatOption, .vatIncluded)
        XCTAssertEqual(replaceItems.additionalDiscountAmount, 100.0)
        XCTAssertEqual(replaceItems.includedVat, true)        
    }
    
    func testReplaceItemsEncode_WithValidValues_ShouldReturnCorrectJson() {
        let items = [
            PurchaseOrderRequest.CreateItem(
                itemId: UUID(),
                kind: .service,
                itemName: "Test Service",
                itemDescription: "Service Description",
                variantId: nil,
                qty: 2.0,
                pricePerUnit: 100.0,
                discountPricePerUnit: 10.0,
                vatRateOption: ._7,
                vatIncluded: false,
                withholdingTaxRateOption: .none
            )
        ]
        let replaceItems = PurchaseOrderRequest.ReplaceItems(
            items: items,
            vatOption: .vatIncluded,
            additionalDiscountAmount: 100.0,
            includedVat: true
        )
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(replaceItems)
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        let itemsArray = jsonObject?["items"] as? [[String: Any]]
        let item = itemsArray?.first
        
        let firstItem = items.first!
        XCTAssertEqual(item?["item_id"] as? String, firstItem.itemId.uuidString)
        XCTAssertEqual(item?["kind"] as? String, firstItem.kind.rawValue)
        XCTAssertEqual(item?["item_name"] as? String, firstItem.itemName)
        XCTAssertEqual(item?["item_description"] as? String, firstItem.itemDescription)
        XCTAssertEqual(item?["qty"] as? Double, firstItem.qty)
        XCTAssertEqual(item?["price_per_unit"] as? Double, firstItem.pricePerUnit)
        XCTAssertEqual(item?["discount_price_per_unit"] as? Double, firstItem.discountPricePerUnit)
        XCTAssertEqual(item?["vat_rate_option"] as? String, firstItem.vatRateOption.rawValue)
        XCTAssertEqual(item?["vat_included"] as? Bool, firstItem.vatIncluded)
        XCTAssertEqual(item?["withholding_tax_rate_option"] as? String, firstItem.withholdingTaxRateOption.rawValue)
        
        
    }
    
    // MARK: - ReorderItems
    
    /*
     struct ReorderItems: Content, Validatable {
         let itemIdOrder: [UUID]
         
         init(itemIdOrder: [UUID]) {
             self.itemIdOrder = itemIdOrder
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.itemIdOrder = try container.decode([UUID].self,
                                               forKey: .itemIdOrder)
         }
         
         enum CodingKeys: String, CodingKey {
             case itemIdOrder = "item_id_order"
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("item_id_order", as: [UUID].self, is: !.empty)
         }
         
     }
     */
    func testReorderItemsInit_WithValidValues_ShouldReturnCorrectValues() {
        let itemIdOrder = [UUID()]
        let reorderItems = PurchaseOrderRequest.ReorderItems(itemIdOrder: itemIdOrder)
        
        XCTAssertEqual(reorderItems.itemIdOrder, itemIdOrder)
    }
    
    func testReorderItemsDecode_WithValidValues_ShouldReturnCorrectValues() {
        let json = """
        {
            "item_id_order": ["00000000-0000-0000-0000-000000000000"]
        }
        """.data(using: .utf8)!
        
        let reorderItems = try! JSONDecoder().decode(PurchaseOrderRequest.ReorderItems.self, from: json)
        
        XCTAssertEqual(reorderItems.itemIdOrder.count, 1)
    }
    
    func testReorderItemEncode_WithValidValues_ShouldReturnCorrectJson() {
        let itemIdOrder = [UUID()]
        let reorderItems = PurchaseOrderRequest.ReorderItems(itemIdOrder: itemIdOrder)
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(reorderItems)
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        let itemIdOrderArray = jsonObject?["item_id_order"] as? [String]
        XCTAssertEqual(itemIdOrderArray?.count, 1)
        XCTAssertEqual(itemIdOrderArray?.first, itemIdOrder.first?.uuidString)
        
        
    }
    
}
