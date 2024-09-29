@testable import App
import XCTVapor

final class PurchaseOrderItemTests: XCTestCase {

    // MARK: - Stub Data for Tests
    struct Stub {
        static var sampleUUID: UUID = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
        static var sampleItem: PurchaseOrderItem {
            let vatRateOption: VatRateOption = ._7
            let taxWithholdingRateOption: TaxWithholdingRateOption = ._3

            return PurchaseOrderItem(
                id: sampleUUID,
                itemId: sampleUUID,
                kind: .product,
                itemName: "Sample Item",
                itemDescription: "Sample Description",
                variantId: sampleUUID,
                qty: 5.0,
                pricePerUnit: 100.0,
                discountPricePerUnit: 10.0,
                additionalDiscount: 5.0,
                vatRateOption: vatRateOption,
                vatIncluded: true,
                taxWithholdingRateOption: taxWithholdingRateOption
            )
        }
    }

    // MARK: - Initialization Tests
    func testInit_WithValidData_ShouldCreateInstance() {
        // Given
        let expectedItem = Stub.sampleItem
        
        // Then
        XCTAssertEqual(expectedItem.id, Stub.sampleUUID)
        XCTAssertEqual(expectedItem.itemId, Stub.sampleUUID)
        XCTAssertEqual(expectedItem.kind, .product)
        XCTAssertEqual(expectedItem.itemName, "Sample Item")
        XCTAssertEqual(expectedItem.itemDescription, "Sample Description")
        XCTAssertEqual(expectedItem.variantId, Stub.sampleUUID)
        XCTAssertEqual(expectedItem.qty, 5.0)
        XCTAssertEqual(expectedItem.pricePerUnit, 100.0)
        XCTAssertEqual(expectedItem.discountPricePerUnit, 10.0)
        XCTAssertEqual(expectedItem.additionalDiscount, 5.0)
        XCTAssertEqual(expectedItem.vatRateOption.value, 0.07)
        XCTAssertTrue(expectedItem.vatIncluded)
        XCTAssertEqual(expectedItem.taxWithholdingRateOption.value, 0.03)
    }
    
    // MARK: - Encoding Tests
    func testEncode_WithValidInstance_ShouldReturnJSON() throws {
        // Given
        let item = Stub.sampleItem
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Then
        XCTAssertEqual(jsonObject?["id"] as? String, Stub.sampleUUID.uuidString)
        XCTAssertEqual(jsonObject?["item_id"] as? String, Stub.sampleUUID.uuidString)
        XCTAssertEqual(jsonObject?["kind"] as? String, "PRODUCT")
        XCTAssertEqual(jsonObject?["item_name"] as? String, "Sample Item")
        XCTAssertEqual(jsonObject?["item_description"] as? String, "Sample Description")
        XCTAssertEqual(jsonObject?["variant_id"] as? String, Stub.sampleUUID.uuidString)
        XCTAssertEqual(jsonObject?["qty"] as? Double, 5.0)
        XCTAssertEqual(jsonObject?["price_per_unit"] as? Double, 100.0)
        XCTAssertEqual(jsonObject?["discount_price_per_unit"] as? Double, 10.0)
        XCTAssertEqual(jsonObject?["additional_discount"] as? Double, 5.0)
        XCTAssertEqual(jsonObject?["vat_rate"] as? Double, 0.07)
        XCTAssertEqual(jsonObject?["vat_rate_option"] as? String, "VAT7")
        XCTAssertEqual(jsonObject?["vat_included"] as? Bool, true)
        XCTAssertEqual(jsonObject?["tax_withholding_rate"] as? Double, 0.03)
        XCTAssertEqual(jsonObject?["tax_withholding_rate_option"] as? String, "TAX3")
    }

    // MARK: - Decoding Tests
    func testDecode_WithValidJSON_ShouldReturnInstance() throws {
        // Given
        let json: [String: Any] = [
            "id": Stub.sampleUUID.uuidString,
            "item_id": Stub.sampleUUID.uuidString,
            "kind": "PRODUCT",
            "item_name": "Sample Item",
            "item_description": "Sample Description",
            "variant_id": Stub.sampleUUID.uuidString,
            "qty": 5.0,
            "price_per_unit": 100.0,
            "discount_price_per_unit": 10.0,
            "additional_discount": 5.0,
            "vat_rate": 0.07,
            "vat_rate_option": "VAT7",
            "vat_included": true,
            "tax_withholding_rate": 0.03,
            "tax_withholding_rate_option": "TAX3",
            "base_discount_per_unit" : 50,
            "amount_discount" : 10,
            "amount_before_vat" : 100,
            "amount_after_vat" : 90,
            "amount_due": 85
        ]
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        
        // When
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(PurchaseOrderItem.self, from: data)
        
        // Then
        XCTAssertEqual(decodedItem.id, Stub.sampleUUID)
        XCTAssertEqual(decodedItem.itemId, Stub.sampleUUID)
        XCTAssertEqual(decodedItem.kind, .product)
        XCTAssertEqual(decodedItem.itemName, "Sample Item")
        XCTAssertEqual(decodedItem.itemDescription, "Sample Description")
        XCTAssertEqual(decodedItem.variantId, Stub.sampleUUID)
        XCTAssertEqual(decodedItem.qty, 5.0)
        XCTAssertEqual(decodedItem.pricePerUnit, 100.0)
        XCTAssertEqual(decodedItem.discountPricePerUnit, 10.0)
        XCTAssertEqual(decodedItem.additionalDiscount, 5.0)
        XCTAssertEqual(decodedItem.vatRate, 0.07)
        XCTAssertEqual(decodedItem.vatRateOption, ._7)
        XCTAssertTrue(decodedItem.vatIncluded)
        XCTAssertEqual(decodedItem.taxWithholdingRate, 0.03)
        XCTAssertEqual(decodedItem.taxWithholdingRateOption, ._3)
        XCTAssertEqual(decodedItem.baseDiscountPerUnit, 50)
        XCTAssertEqual(decodedItem.amountDiscount, 10)
        XCTAssertEqual(decodedItem.amountBeforeVat, 100)
        XCTAssertEqual(decodedItem.amountAfterVat, 90)
        XCTAssertEqual(decodedItem.amountDue, 85)
        
    }
}


//final class PurchaseOrderItemTests: XCTestCase {
    
    // Price included VAT , Tax withholding included
//    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
//        // Given
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: VatRate = ._7
//        let taxWithholdingRate: TaxWithholdingRate = ._3
//        
//        // When
//        
//        let item = PurchaseOrderItem(itemId: itemId,
//                                     kind: .product,
//                                     name: name,
//                                     description: description,
//                                     qty: qty,
//                                     pricePerUnit: pricePerUnit,
//                                     discountPricePerUnit: discountPerUnit,
//                                     additionalDiscount: 0,
//                                     vatRateOption: vatRate,
//                                     vatIncluded: true,
//                                     taxWithholdingRate: taxWithholdingRate)
//        
//        // Then
//        let expectedTotalAmountDiscount = 10.0
//        let expectedVatAmountAfter = 90.0
//                        
//        let expectedTotalAmountBeforeVat = 84.1121495327
//        let expectedVatAmount = 5.8878504673
//
//        let expectedTaxWithholdingAmount = 2.523364486 // tax amount
//        let expectedTotalPayAmount = 87.476635514
//        
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//
//        // vat
//        XCTAssertNotNil(item.vat)
//        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
//
//        // tax withholding
//        XCTAssertNotNil(item.taxWithholding)
//        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)
//
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//    }
    
    // Price excluded VAT , Tax withholding included
//    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
//        // given        
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: Double = 0.07
//        let taxWithholdingRate: Double = 0.03
//
//        // when
//        let item = PurchaseOrderItem(itemId: itemId,
//                                                  name: name,
//                                                  description: description,
//                                                  variant: variant,
//                                                  qty: qty,
//                                                  pricePerUnitExcludeVat: pricePerUnit,
//                                                  discountPerUnit: discountPerUnit,
//                                                  vatRateOption: vatRate,
//                                                  taxWithholdingRate: taxWithholdingRate)
//
//        // then
//        let expectedTotalAmountDiscount = 10.0
//        
//        let expectedTotalAmountBeforeVat = 90.0
//        let expectedVatAmount = 6.3
//        let expectedVatAmountAfter = 96.3
//
//        let expectedTaxWithholdingAmount = 2.7
//
//        let expectedTotalPayAmount = 93.6
//
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//
//        // vat
//        XCTAssertNotNil(item.vat)
//        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
//
//        // tax withholding
//        XCTAssertNotNil(item.taxWithholding)
//        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)
//
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//    }
//
//    // Price included 0 VAT , 0 Tax withholding excluded
//    func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_ShouldCalculateCorrectValues() {
//        // given
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: Double = 0
//        let taxWithholdingRate: Double = 0
//        
//        // when
//        let item = PurchaseOrderItem(itemId: itemId,
//                                     name: name,
//                                     description: description,
//                                     variant: variant,
//                                     qty: qty,
//                                     pricePerUnitIncludeVat: pricePerUnit,
//                                     discountPerUnit: discountPerUnit,
//                                     vatRateOption: vatRate,
//                                     taxWithholdingRate: taxWithholdingRate)
//        
//        // then
//        let expectedTotalAmountDiscount = 10.0
//        let expectedVatAmountAfter = 90.0
//
//        let expectedTotalAmountBeforeVat = 90.0
//        let expectedVatAmount = 0.0
//
//        let expectedTaxWithholdingAmount = 0.0
//
//        let expectedTotalPayAmount = 90.0
//
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//
//        // vat
//        XCTAssertNotNil(item.vat)
//        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
//
//        // tax withholding
//        XCTAssertNotNil(item.taxWithholding)
//        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)
//
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//        
//
//    }    
//    
//    // Price included VAT , No Tax withholding
//    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
//        // given
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: Double = 0.07
//        let taxWithholdingRate: Double? = nil
//        
//        // when
//        let item = PurchaseOrderItem(itemId: itemId,
//                                     name: name,
//                                     description: description,
//                                     variant: variant,
//                                     qty: qty,
//                                     pricePerUnitIncludeVat: pricePerUnit,
//                                     discountPerUnit: discountPerUnit,
//                                     vatRateOption: vatRate,
//                                     taxWithholdingRate: taxWithholdingRate)
//        
//        // then
//        let expectedTotalAmountDiscount = 10.0
//        let expectedVatAmountAfter = 90.0
//                        
//        let expectedTotalAmountBeforeVat = 84.1121495327
//        let expectedVatAmount = 5.8878504673
//
//        let expectedTotalPayAmount = 90.0
//        
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//        
//        // vat
//        XCTAssertNotNil(item.vat)
//        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
//        
//        // tax withholding
//        XCTAssertNil(item.taxWithholding)
//        
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//        
//    }
//    
//    // Price excluded VAT , No Tax withholding
//    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
//        // given
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: Double = 0.07
//        let taxWithholdingRate: Double? = nil
//        
//        // when
//        let item = PurchaseOrderItem(itemId: itemId,
//                                     name: name,
//                                     description: description,
//                                     variant: variant,
//                                     qty: qty,
//                                     pricePerUnitExcludeVat: pricePerUnit,
//                                     discountPerUnit: discountPerUnit,
//                                     vatRateOption: vatRate,
//                                     taxWithholdingRate: taxWithholdingRate)
//        
//        // then
//        let expectedTotalAmountDiscount = 10.0
//        let expectedVatAmountAfter = 96.3
//        
//        let expectedTotalAmountBeforeVat = 90.0
//        let expectedVatAmount: Double = 6.3
//        
//        let expectedTotalPayAmount = 96.3
//        
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//        
//        // vat
//        XCTAssertNotNil(item.vat)
//        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
//        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
//        
//        // tax withholding
//        XCTAssertNil(item.taxWithholding)
//        
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//        
//    }
//
//    // Price No VAT , With Tax withholding
//    func testInit_WithNoVat_WithTaxWithholding_ShouldCalculateCorrectValues() {
//        // given
//        let itemId = UUID()
//        let name = "Test Item"
//        let description = "Test Description"
//        let variant: ProductVariant? = nil
//        let qty: Double = 10
//        let pricePerUnit: Double = 10
//        let discountPerUnit: Double = 1
//        let vatRateOption: Double? = nil
//        let taxWithholdingRate: Double = 0.03
//        
//        // when
//        let item = PurchaseOrderItem(itemId: itemId,
//                                     name: name,
//                                     description: description,
//                                     variant: variant,
//                                     qty: qty,
//                                     pricePerUnitExcludeVat: pricePerUnit,
//                                     discountPerUnit: discountPerUnit,
//                                     vatRateOption: vatRate,
//                                     taxWithholdingRate: taxWithholdingRate)
//        
//        // then
//        let expectedTotalAmountDiscount = 10.0
//        let expectedVatAmountAfter = 90.0
//        
//        let expectedTotalAmountBeforeVat = 90.0
//        
//        let expectedTaxWithholdingAmount = 2.7
//        
//        let expectedTotalPayAmount = 87.3
//        
//        //test property
//        XCTAssertEqual(item.name, name)
//        XCTAssertEqual(item.description, description)
//        XCTAssertEqual(item.qty, qty)
//        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
//        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
//        
//        // vat
//        XCTAssertNil(item.vat)
//        
//        // tax withholding
//        XCTAssertNotNil(item.taxWithholding)
//        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.rate, taxWithholdingRate, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
//        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)
//        
//        // other
//        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
//        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
//        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
//        
//        
//    }

//}

//extension PurchaseOrderItemTests {
//    struct Stub {
//        static var samplePurchaseOrderItem: PurchaseOrderItem {
//            return PurchaseOrderItem(itemId: UUID(), name: "Test Item", description: "Test Description", variant: nil, qty: 10, pricePerUnitIncludeVat: 10, discountPerUnit: 1, vatRateOption: 0.07, taxWithholdingRate: 0.03)
//        }
//    }
//}
