//
//  BillItemTests.swift
//
//
//  Created by IntrodexMac on 23/6/2567 BE.
//

@testable import App
import XCTVapor

class BillItemTests: XCTestCase {
    
    func testInit_WithValidValues_ShouldCreateInstance() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: 0.03,
                            vatIncluded: true)
        
        XCTAssertEqual(item.description, "Test Item")
        XCTAssertEqual(item.quantity, 10, accuracy: 0.01)
        XCTAssertEqual(item.pricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.discountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertNotNil(item.vatRate)
        XCTAssertEqual(item.vatRate!, 0.07, accuracy: 0.01)
        XCTAssertNotNil(item.withholdingTaxRate)
        XCTAssertEqual(item.withholdingTaxRate!, 0.03, accuracy: 0.01)
        XCTAssertTrue(item.vatIncluded)
    }
    
    // Price included VAT , Tax withholding included
    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: 0.03,
                            vatIncluded: true)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 9.3457943925, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 0.9345794393, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 93.457943925, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 9.345794393, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 84.112149532, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 5.8878504673, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 90, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 2.523364486, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 87.476635514, accuracy: 0.01)
    }
    
    // Price excluded VAT , Tax withholding included
    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: 0.03,
                            vatIncluded: false)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 90.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 6.3, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 96.3, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 2.7, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 93.6, accuracy: 0.01)
        
    }

    // Price included 0 VAT , 0 Tax withholding excluded
    func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.0,
                            withholdingTaxRate: 0.0,
                            vatIncluded: true)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 90, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 0.0, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 90, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 90, accuracy: 0.01)
    }

    // Price included VAT , No Tax withholding
    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: nil,
                            vatIncluded: true)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 9.3457943925, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 0.9345794393, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 93.457943925, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 9.345794393, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 84.112149532, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 5.8878504673, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 90, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 90.0, accuracy: 0.01)
    }
    
    // Price excluded VAT , No Tax withholding
    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: nil,
                            vatIncluded: false)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 90.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 6.3, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 96.3, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 96.3, accuracy: 0.01)
    }

    // Price No VAT , With Tax withholding
    func testInit_WithNoVat_WithTaxWithholding_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: nil,
                            withholdingTaxRate: 0.03,
                            vatIncluded: false)
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat()
        XCTAssertEqual(amountBeforeVat, 90.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount()
        XCTAssertEqual(vatAmount, 0.0, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat()
        XCTAssertEqual(amountAfterVat, 90.0, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount()
        XCTAssertEqual(withholdingTaxAmount, 2.7, accuracy: 0.01)
        
        let amountDue = item.amountDue()
        XCTAssertEqual(amountDue, 87.3, accuracy: 0.01)
    }
    
    //MARK: additional discount
    
    // Price included VAT , Tax withholding included , additional discount
    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: 0.03,
                            vatIncluded: true)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 9.3457943925, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 0.9345794393, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 93.457943925, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 9.345794393, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 74.77, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 5.23, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 80.0, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 2.24, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 77.76, accuracy: 0.01)
    }
    
    // Price excluded VAT , Tax withholding included , additional discount
    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: 0.03,
                            vatIncluded: false)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 80.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 5.6, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 85.6, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 2.4, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 83.2, accuracy: 0.01)
    }
    
    // Price included 0 VAT , 0 Tax withholding excluded , additional discount
    func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.0,
                            withholdingTaxRate: 0.0,
                            vatIncluded: true)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 80, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 0.0, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 80, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 80, accuracy: 0.01)
    }
    
    
    // Price included VAT , No Tax withholding , additional discount
    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: nil,
                            vatIncluded: true)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 9.3457943925, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 0.9345794393, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 93.457943925, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 9.345794393, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 74.77, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 5.23, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 80.0, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 80.0, accuracy: 0.01)
    }

    // Price excluded VAT , No Tax withholding , additional discount
    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: 0.07,
                            withholdingTaxRate: nil,
                            vatIncluded: false)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 80.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 5.6, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 85.6, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 0.0, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 85.6, accuracy: 0.01)
    }

    // Price No VAT , With Tax withholding , additional discount
    func testInit_WithNoVat_WithTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item = BillItem(description: "Test Item",
                            quantity: 10.0,
                            pricePerUnit: 10.0,
                            discountPerUnit: 1.0,
                            vatRate: nil,
                            withholdingTaxRate: 0.03,
                            vatIncluded: false)
        let additionalDiscount = 10.0
        
        // test compute
        XCTAssertEqual(item.basePricePerUnit, 10.0, accuracy: 0.01)
        XCTAssertEqual(item.baseDiscountPerUnit, 1.0, accuracy: 0.01)
        XCTAssertEqual(item.amountBeforeDiscount, 100.0, accuracy: 0.01)
        XCTAssertEqual(item.amountDiscount, 10.0, accuracy: 0.01)
        
        let amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountBeforeVat, 80.0, accuracy: 0.01)
        
        let vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(vatAmount, 0.0, accuracy: 0.01)
        
        let amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountAfterVat, 80.0, accuracy: 0.01)
        
        let withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(withholdingTaxAmount, 2.4, accuracy: 0.01)
        
        let amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
        XCTAssertEqual(amountDue, 77.6, accuracy: 0.01)
    }
}


/*
 
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
 */
