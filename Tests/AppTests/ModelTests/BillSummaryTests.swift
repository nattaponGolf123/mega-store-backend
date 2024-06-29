//
//  BillSummaryTests.swift
//
//
//  Created by IntrodexMac on 23/6/2567 BE.
//

@testable import App
import XCTVapor

class BillSummaryTests: XCTestCase {
    
    func testInit_WithValidValues_ShouldCreateInstance() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 5.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.items.count, 2)
        XCTAssertEqual(summary.additionalDiscountAmount, 5, accuracy: 0.01)
        
    }
    
    // All item price included VAT , All item tax withholding included
    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878505, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 168.2242990654, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.78, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.05, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.95, accuracy: 0.01)
        
    }
    
    // All item price excluded VAT , All item tax withholding included
    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 12.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 192.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.4, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 187.20, accuracy: 0.01)
        
    }
    
    // All item price included 0 VAT , All item tax withholding included
    func testInit_WithVatZeroIncluded_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.4, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.60, accuracy: 0.01)
    }
    
    // All item price included VAT , All item tax withholding excluded
    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878504673, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 168.22, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.78, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 180, accuracy: 0.01)
    }
    
    // All item price excluded VAT , All item tax withholding excluded
    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 12.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 192.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 192.6, accuracy: 0.01)
    }
    
    // All item price No VAT , All item tax withholding included
    func testInit_WithNoVat_WithTaxWithholding_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: nil,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: nil,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.4, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.6, accuracy: 0.01)
    }
    
    //MARK: additional discount
    
    // All item price included VAT , All item tax withholding included , additional discount
    func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878505, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 158.88, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.12, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 4.77, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 165.23, accuracy: 0.01)
    }
    
    // All item price excluded VAT , All item tax withholding included , additional discount
    func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.9, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 181.9, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.1, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 176.8, accuracy: 0.01)
    }
    
    // All item price included 0 VAT , All item tax withholding included , additional discount
    func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.1, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 164.9, accuracy: 0.01)
    }
    
    // All item price included VAT , All item tax withholding excluded , additional discount
    func testInit_WithPriceIncludedVat_WithNoTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: true)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878504673, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 158.88, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.12, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 170, accuracy: 0.01)
    }
    
    // All item price excluded VAT , All item tax withholding excluded , additional discount
    func testInit_WithPriceExcludedVat_WithNoTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 11.9, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 181.9, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 181.9, accuracy: 0.01)
    }
    
    // All item price No VAT , All item tax withholding included , additional discount
    func testInit_WithNoVat_WithTaxWithholding_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: nil,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: nil,
                             withholdingTaxRate: 0.03,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: false)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.1, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 164.9, accuracy: 0.01)
    }
    
    // MARK: with vat adjuestment
    
    // Scenario: Positive VAT adjustment
    func testInit_WithPositiveVatAdjustment_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true,
                                  vatAdjustment: 5.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878505, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 163.2242990654, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 16.78, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.05, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.95, accuracy: 0.01)
    }
    
    // Scenario: Negative VAT adjustment
    func testInit_WithNegativeVatAdjustment_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true,
                                  vatAdjustment: -5.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878505, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 173.2242990654, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 6.78, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.05, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.95, accuracy: 0.01)
    }

    // Scenario: VAT adjustment with additional discount
    func testInit_WithVatAdjustment_WithAdditionalDiscount_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 10.0,
                                  vatIncluded: true,
                                  vatAdjustment: 3.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878505, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 155.88, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 14.12, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 170, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 4.77, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 165.23, accuracy: 0.01)
    }
    
    // Scenario: VAT adjustment with no VAT included
    func testInit_WithVatAdjustment_WithNoVatIncluded_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: false)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: false,
                                  vatAdjustment: 5.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 175, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 17.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 192.6, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 192.6, accuracy: 0.01)
    }
    
    // Scenario: VAT adjustment with zero VAT
    func testInit_WithVatAdjustment_WithZeroVat_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.0,
                             withholdingTaxRate: 0.03,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true,
                                  vatAdjustment: 5.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 200, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 175, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 5.0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 5.4, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 174.6, accuracy: 0.01)
    }
    
    // Scenario: VAT adjustment with no withholding tax
    func testInit_WithVatAdjustment_WithNoWithholdingTax_ShouldCalculateCorrectValues() {
        let item1 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let item2 = BillItem(description: "Test Item",
                             quantity: 10.0,
                             pricePerUnit: 10.0,
                             discountPerUnit: 1.0,
                             vatRate: 0.07,
                             withholdingTaxRate: nil,
                             vatIncluded: true)
        
        let summary = BillSummary(items: [item1, item2],
                                  additionalDiscountAmount: 0.0,
                                  vatIncluded: true,
                                  vatAdjustment: 5.0)
        
        XCTAssertEqual(summary.totalAmountBeforeDiscount, 186.9158878504673, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountBeforeVat, 163.22, accuracy: 0.01)
        XCTAssertEqual(summary.totalVatAmount, 16.78, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountAfterVat, 180, accuracy: 0.01)
        XCTAssertEqual(summary.totalWithholdingTaxAmount, 0, accuracy: 0.01)
        XCTAssertEqual(summary.totalAmountDue, 180, accuracy: 0.01)
    }
}


/*
 struct BillSummary {
     let items: [BillItem]
     let additionalDiscountAmount: Double // Additional discount amount
     let totalDiscountPerItem: Double
     let vatAdjustment: Double // Vat adjustment
     
     init(items: [BillItem],
          additionalDiscountAmount: Double = 0,
          vatIncluded: Bool,
          vatAdjustment: Double = 0) {
         self.items = items
         self.additionalDiscountAmount = additionalDiscountAmount
         self.totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
         self.vatAdjustment = vatAdjustment
     }
        
     var totalAmountBeforeDiscount: Double {
         return items.reduce(0) { $0 + $1.amountBeforeDiscount }
     }
     
     var totalAmountBeforeVat: Double {
         let sum = items.reduce(0) { $0 + $1.amountBeforeVat(withAdditionalDiscount: totalDiscountPerItem) }
         return sum - vatAdjustment
     }
         
     var totalAmountAfterVat: Double {
         return items.reduce(0) { $0 + $1.amountAfterVat(withAdditionalDiscount: totalDiscountPerItem) }
     }
     
     var totalVatAmount: Double {
         let sum = items.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: totalDiscountPerItem) }
         return sum + vatAdjustment
     }
     
     var totalWithholdingTaxAmount: Double {
         return items.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: totalDiscountPerItem) }
     }
     
     //totalPayable
     var totalAmountDue: Double {
         return totalAmountAfterVat - totalWithholdingTaxAmount
     }
     
 }

 */
