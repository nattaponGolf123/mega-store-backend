@testable import App
import XCTVapor

final class PurchaseOrderItemTests: XCTestCase {
    
    // Price included VAT , Tax withholding included
    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        // Given
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double = 0.07
        let taxWithholdingRate: Double = 0.03
        
        // When
        let item = PurchaseOrderItem(itemId: itemId,
                                                  name: name,
                                                  description: description,
                                                  variant: variant,
                                                  qty: qty,
                                                  pricePerUnitIncludeVat: pricePerUnit,
                                                  discountPerUnit: discountPerUnit,
                                                  vatRate: vatRate,
                                                  taxWithholdingRate: taxWithholdingRate)
        
        // Then
        let expectedTotalAmountDiscount = 10.0
        let expectedVatAmountAfter = 90.0
                        
        let expectedTotalAmountBeforeVat = 84.1121495327
        let expectedVatAmount = 5.8878504673

        let expectedTaxWithholdingAmount = 2.523364486 // tax amount
        let expectedTotalPayAmount = 87.476635514
        
        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

        // vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)

        // tax withholding
        XCTAssertNotNil(item.taxWithholding)
        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)

        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
    }
    
    // Price excluded VAT , Tax withholding included
    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        // given        
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double = 0.07
        let taxWithholdingRate: Double = 0.03

        // when
        let item = PurchaseOrderItem(itemId: itemId,
                                                  name: name,
                                                  description: description,
                                                  variant: variant,
                                                  qty: qty,
                                                  pricePerUnitExcludeVat: pricePerUnit,
                                                  discountPerUnit: discountPerUnit,
                                                  vatRate: vatRate,
                                                  taxWithholdingRate: taxWithholdingRate)

        // then
        let expectedTotalAmountDiscount = 10.0
        
        let expectedTotalAmountBeforeVat = 90.0
        let expectedVatAmount = 6.3
        let expectedVatAmountAfter = 96.3

        let expectedTaxWithholdingAmount = 2.7

        let expectedTotalPayAmount = 93.6

        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

        // vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)

        // tax withholding
        XCTAssertNotNil(item.taxWithholding)
        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)

        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
    }

    // Price included 0 VAT , 0 Tax withholding excluded
    func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_ShouldCalculateCorrectValues() {
        // given
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double = 0
        let taxWithholdingRate: Double = 0
        
        // when
        let item = PurchaseOrderItem(itemId: itemId,
                                     name: name,
                                     description: description,
                                     variant: variant,
                                     qty: qty,
                                     pricePerUnitIncludeVat: pricePerUnit,
                                     discountPerUnit: discountPerUnit,
                                     vatRate: vatRate,
                                     taxWithholdingRate: taxWithholdingRate)
        
        // then
        let expectedTotalAmountDiscount = 10.0
        let expectedVatAmountAfter = 90.0

        let expectedTotalAmountBeforeVat = 90.0
        let expectedVatAmount = 0.0

        let expectedTaxWithholdingAmount = 0.0

        let expectedTotalPayAmount = 90.0

        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

        // vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)

        // tax withholding
        XCTAssertNotNil(item.taxWithholding)
        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)

        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
        

    }    
    
    // Price included VAT , No Tax withholding
    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        // given
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double = 0.07
        let taxWithholdingRate: Double? = nil
        
        // when
        let item = PurchaseOrderItem(itemId: itemId,
                                     name: name,
                                     description: description,
                                     variant: variant,
                                     qty: qty,
                                     pricePerUnitIncludeVat: pricePerUnit,
                                     discountPerUnit: discountPerUnit,
                                     vatRate: vatRate,
                                     taxWithholdingRate: taxWithholdingRate)
        
        // then
        let expectedTotalAmountDiscount = 10.0
        let expectedVatAmountAfter = 90.0
                        
        let expectedTotalAmountBeforeVat = 84.1121495327
        let expectedVatAmount = 5.8878504673

        let expectedTotalPayAmount = 90.0
        
        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
        
        // vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
        
        // tax withholding
        XCTAssertNil(item.taxWithholding)
        
        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
        
    }
    
    // Price excluded VAT , No Tax withholding
    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        // given
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double = 0.07
        let taxWithholdingRate: Double? = nil
        
        // when
        let item = PurchaseOrderItem(itemId: itemId,
                                     name: name,
                                     description: description,
                                     variant: variant,
                                     qty: qty,
                                     pricePerUnitExcludeVat: pricePerUnit,
                                     discountPerUnit: discountPerUnit,
                                     vatRate: vatRate,
                                     taxWithholdingRate: taxWithholdingRate)
        
        // then
        let expectedTotalAmountDiscount = 10.0
        let expectedVatAmountAfter = 96.3
        
        let expectedTotalAmountBeforeVat = 90.0
        let expectedVatAmount: Double = 6.3
        
        let expectedTotalPayAmount = 96.3
        
        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
        
        // vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.0001)
        XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.0001)
        
        // tax withholding
        XCTAssertNil(item.taxWithholding)
        
        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
        
    }

    // Price No VAT , With Tax withholding
    func testInit_WithNoVat_WithTaxWithholding_ShouldCalculateCorrectValues() {
        // given
        let itemId = UUID()
        let name = "Test Item"
        let description = "Test Description"
        let variant: ProductVariant? = nil
        let qty: Double = 10
        let pricePerUnit: Double = 10
        let discountPerUnit: Double = 1
        let vatRate: Double? = nil
        let taxWithholdingRate: Double = 0.03
        
        // when
        let item = PurchaseOrderItem(itemId: itemId,
                                     name: name,
                                     description: description,
                                     variant: variant,
                                     qty: qty,
                                     pricePerUnitExcludeVat: pricePerUnit,
                                     discountPerUnit: discountPerUnit,
                                     vatRate: vatRate,
                                     taxWithholdingRate: taxWithholdingRate)
        
        // then
        let expectedTotalAmountDiscount = 10.0
        let expectedVatAmountAfter = 90.0
        
        let expectedTotalAmountBeforeVat = 90.0
        
        let expectedTaxWithholdingAmount = 2.7
        
        let expectedTotalPayAmount = 87.3
        
        //test property
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.description, description)
        XCTAssertEqual(item.qty, qty)
        XCTAssertEqual(item.pricePerUnit, pricePerUnit)
        XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
        
        // vat
        XCTAssertNil(item.vat)
        
        // tax withholding
        XCTAssertNotNil(item.taxWithholding)
        XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.rate, taxWithholdingRate, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.0001)
        XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.0001)
        
        // other
        XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.0001)
        XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.0001)
        XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.0001)
        
        
    }

}

extension PurchaseOrderItemTests {
    struct Stub {
        static var samplePurchaseOrderItem: PurchaseOrderItem {
            return PurchaseOrderItem(itemId: UUID(), name: "Test Item", description: "Test Description", variant: nil, qty: 10, pricePerUnitIncludeVat: 10, discountPerUnit: 1, vatRate: 0.07, taxWithholdingRate: 0.03)
        }
    }
}
