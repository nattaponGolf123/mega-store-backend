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

