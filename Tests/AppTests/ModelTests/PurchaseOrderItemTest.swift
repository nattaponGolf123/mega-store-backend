@testable import App
import XCTVapor

final class PurchaseOrderItemTests: XCTestCase {
    
    // Stub data for testing
    struct Stub {
        static var itemId: UUID { UUID() }
        static var name: String { "Sample Item" }
        static var description: String { "Sample Description" }
        static var variant: ProductVariant? { nil } // Assuming ProductVariant is defined elsewhere
//        static var qty: Double { 10.0 }
//        static var pricePerUnit: Double { 100.0 }
//        static var discountPerUnit: Double { 5.0 }
//        static var vatRate: Double { 0.07 }
//        static var taxWithholdingRate: Double { 0.03 }
//
//        static var totalAmountAfterDiscount: Double {
//            (Stub.qty * Stub.pricePerUnit) - (Stub.qty * Stub.discountPerUnit)
//        }
//
//        static var totalAmountAfterVat: Double {
//            Stub.totalAmountAfterDiscount * (1 + Stub.vatRate)
//        }
//
//        static var totalAmountAfterTaxWithholding: Double {
//            Stub.totalAmountAfterVat - (Stub.totalAmountAfterVat * Stub.taxWithholdingRate)
//        }

    }
    
    func testInit_WithValidParameters_ShouldInitializeCorrectly() {
        let item = PurchaseOrderItem(
            id: nil,
            itemId: Stub.itemId,
            name: Stub.name,
            description: Stub.description,
            variant: Stub.variant,
            qty: 10.0,
            pricePerUnit: 100.0,
            discountPerUnit: 5.0,
            vatRate: 0.07,
            taxWithholdingRate: 0.03,
            isVatIncluded: false
        )

        let vatRate: Double = 0.07
        let taxWithholdingRate: Double = 0.03
        
        
        let totalAmountBeforeDiscount = 10.0 * 100.0 // 1_000
        let totalDiscountAmount = 10.0 * 5.0 // 50
        let totalAmountAfterDiscount = totalAmountBeforeDiscount - totalDiscountAmount // 950
        
        let vatAmount = totalAmountAfterDiscount * vatRate // 66.5
        let totalAmountAfterVat = totalAmountAfterDiscount + vatAmount // 1016.5
        
        //let vatAmountBeforeVat = totalAmountAfterDiscount
        //let vatAmount = totalAmountAfterVat - totalAmount
        //let vatAmountAfterVat = totalAmountAfterVat
        
        let taxWithholdingAmount = totalAmountAfterVat * taxWithholdingRate // 28.5

        //let taxWithholdingAmountBeforeTaxWithholding = totalAmountAfterVat
        let totalAmountAfterTaxWithholding = totalAmountAfterDiscount - taxWithholdingAmount
        
        
        XCTAssertNotNil(item.itemId)
        XCTAssertEqual(item.name, Stub.name)
        XCTAssertEqual(item.description, Stub.description)
        XCTAssertEqual(item.qty, 10)
        XCTAssertEqual(item.pricePerUnit, 100.0)
        XCTAssertEqual(item.discountPricePerUnit, 5.0, accuracy: 0.001)
        XCTAssertEqual(item.totalDiscountAmount, totalDiscountAmount, accuracy: 0.001)
        XCTAssertEqual(item.totalAmount, totalAmountAfterDiscount, accuracy: 0.001)
        XCTAssertEqual(item.totalPayAmount, totalAmountAfterTaxWithholding, accuracy: 0.001)

        //test vat
        XCTAssertNotNil(item.vat)
        XCTAssertEqual(item.vat!.amount, vatAmount)
        XCTAssertEqual(item.vat!.rate, 0.07, accuracy: 0.001)
        XCTAssertEqual(item.vat!.amountBefore, totalAmountAfterDiscount, accuracy: 0.001)
        XCTAssertEqual(item.vat!.amountAfter, totalAmountAfterVat, accuracy: 0.001)

        // test tax withholding
        XCTAssertNotNil(item.taxWithholding)
        XCTAssertEqual(item.taxWithholding!.amountBefore , totalAmountAfterVat, accuracy: 0.001)
        XCTAssertEqual(item.taxWithholding!.amount, taxWithholdingAmount, accuracy: 0.001)
        XCTAssertEqual(item.taxWithholding!.rate, 0.03, accuracy: 0.001)
        XCTAssertEqual(item.taxWithholding!.amountAfter, totalAmountAfterTaxWithholding, accuracy: 0.001)

    }
    
//    func testTotalAmount_WithVatIncluded_ShouldCalculateCorrectly() {
//        let item = PurchaseOrderItem(
//            id: nil,
//            itemId: Stub.itemId,
//            name: Stub.name,
//            description: Stub.description,
//            variant: Stub.variant,
//            qty: Stub.qty,
//            pricePerUnit: Stub.pricePerUnit,
//            discountPerUnit: Stub.discountPerUnit,
//            vatRate: Stub.vatRate,
//            taxWithholdingRate: Stub.taxWithholdingRate,
//            isVatIncluded: true
//        )
//
//        let totalAmountAfterDiscount = (Stub.qty * Stub.pricePerUnit) - (Stub.qty * Stub.discountPerUnit)
//
//        XCTAssertEqual(item.totalAmount, totalAmountAfterDiscount)
//        XCTAssertEqual(item.vat?.amountAfterVat, totalAmountAfterDiscount)
//    }
//
//    func testTotalAmount_WithoutVatIncluded_ShouldCalculateCorrectly() {
//        let item = PurchaseOrderItem(
//            id: nil,
//            itemId: Stub.itemId,
//            name: Stub.name,
//            description: Stub.description,
//            variant: Stub.variant,
//            qty: Stub.qty,
//            pricePerUnit: Stub.pricePerUnit,
//            discountPerUnit: Stub.discountPerUnit,
//            vatRate: Stub.vatRate,
//            taxWithholdingRate: Stub.taxWithholdingRate,
//            isVatIncluded: false
//        )
//
//        let totalAmountAfterDiscount = (Stub.qty * Stub.pricePerUnit) - (Stub.qty * Stub.discountPerUnit)
//
//        XCTAssertEqual(item.totalAmount, totalAmountAfterDiscount)
//        XCTAssertEqual(item.vat?.amountBeforeVat, totalAmountAfterDiscount)
//    }
//
//    func testTotalPayAmount_WithTaxWithholding_ShouldCalculateCorrectly() {
//        let item = PurchaseOrderItem(
//            id: nil,
//            itemId: Stub.itemId,
//            name: Stub.name,
//            description: Stub.description,
//            variant: Stub.variant,
//            qty: Stub.qty,
//            pricePerUnit: Stub.pricePerUnit,
//            discountPerUnit: Stub.discountPerUnit,
//            vatRate: Stub.vatRate,
//            taxWithholdingRate: Stub.taxWithholdingRate,
//            isVatIncluded: true
//        )
//
//        let totalAmountAfterDiscount = (Stub.qty * Stub.pricePerUnit) - (Stub.qty * Stub.discountPerUnit)
//
//        let vatAmount = VatAmount(totalAmountIncludeVat: totalAmountAfterDiscount, rate: Stub.vatRate)
//        let taxWithholding = TaxWithholding(totalAmount: vatAmount.amountAfterVat, rate: Stub.taxWithholdingRate)
//
//        XCTAssertEqual(item.totalPayAmount, taxWithholding.amountAfterTaxWithholding)
//    }
//
//    func testConvenienceInit_WithPricePerUnitIncludeVat_ShouldInitializeCorrectly() {
//        let item = PurchaseOrderItem(
//            id: nil,
//            itemId: Stub.itemId,
//            name: Stub.name,
//            description: Stub.description,
//            variant: Stub.variant,
//            qty: Stub.qty,
//            pricePerUnit: Stub.pricePerUnit,
//            discountPerUnit: Stub.discountPerUnit,
//            vatRate: Stub.vatRate,
//            taxWithholdingRate: Stub.taxWithholdingRate,
//            isVatIncluded: true
//        )
//
//        XCTAssertEqual(item.pricePerUnit, Stub.pricePerUnit)
//        XCTAssertTrue(item.vat != nil)
//    }
//
//    func testConvenienceInit_WithPricePerUnitExcludeVat_ShouldInitializeCorrectly() {
//        let item = PurchaseOrderItem(
//            id: nil,
//            itemId: Stub.itemId,
//            name: Stub.name,
//            description: Stub.description,
//            variant: Stub.variant,
//            qty: Stub.qty,
//            pricePerUnit: Stub.pricePerUnit,
//            discountPerUnit: Stub.discountPerUnit,
//            vatRate: Stub.vatRate,
//            taxWithholdingRate: Stub.taxWithholdingRate,
//            isVatIncluded: false
//        )
//
//        XCTAssertEqual(item.pricePerUnit, Stub.pricePerUnit)
//        XCTAssertTrue(item.vat != nil)
//    }
}


/*

final class ContactCodeTests: XCTestCase {
    
    // Test Initialization
    func testInit_WithValidNumber_ShouldSetCodeWithPrefix() {
        let contactCode = ContactCode(number: 123)
        XCTAssertEqual(contactCode.code, "C00123")
    }
    
    // Test static method getNumber(from:)
    func testGetNumber_WithValidCode_ShouldReturnNumber() {
        let code = "C123"
        let number = ContactCode.getNumber(from: code)
        XCTAssertEqual(number, 123)
    }
    
    func testGetNumber_WithInvalidCode_ShouldReturnNil() {
        let code = "123"
        let number = ContactCode.getNumber(from: code)
        XCTAssertNotNil(number)
    }
    
    func testGetNumber_WithNonNumericCode_ShouldReturnNil() {
        let code = "Cabc"
        let number = ContactCode.getNumber(from: code)
        XCTAssertNil(number)
    }
    
    func testCodeProperty_WithPrefixBehavior_ShouldAddPrefix() {
        let contactCode = ContactCode(number: 456)
        XCTAssertEqual(contactCode.code, "C00456")
    }
    
}

*/

/*

import Vapor
import Fluent

final class PurchaseOrderItem: Model, Content {
    static let schema = "PurchaseOrderItems"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "item_id")
    var itemId: UUID
    
    @Enum(key: "kind")
    var kind: Kind
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "variant")
    var variant: ProductVariant?
    
    @Field(key: "qty")
    var qty: Double
    
    @Field(key: "price_per_unit")
    var pricePerUnit: Double
    
    @Field(key: "discount_price_per_unit")
    var discountPricePerUnit: Double
    
    @Field(key: "total_discount_amount")
    var totalDiscountAmount: Double?
    
    @Field(key: "vat")
    var vat: VatAmount?
    
    @Field(key: "tax_withholding")
    var taxWithholding: TaxWithholding?
    
    @Field(key: "total_amount")
    var totalAmount: Double
    
    @Field(key: "total_pay_amount")
    var totalPayAmount: Double
    
    init() { }
    
    init(id: UUID? = nil,
         itemId: UUID,
         name: String,
         description: String,
         variant: ProductVariant?,
         qty: Double,
         pricePerUnit: Double,
         discountPerUnit: Double = 0,
         vatRate: Double?,
         taxWithholdingRate: Double?,
         isVatIncluded: Bool) {
        
        self.id = id
        self.itemId = itemId
        self.name = name
        self.description = description
        self.variant = variant
        self.qty = qty
        self.pricePerUnit = pricePerUnit
        self.discountPricePerUnit = discountPerUnit
        
        self.totalDiscountAmount = discountPerUnit * qty
        
        // Calculation part
        let rawTotalAmount = qty * pricePerUnit
        
        // Discount
        let totalAmountAfterDiscount = rawTotalAmount - (discountPerUnit * qty)
        
        // Vat
        if isVatIncluded {
            self.totalAmount = totalAmountAfterDiscount
            self.vat = vatRate.map { VatAmount(totalAmountIncludeVat: totalAmountAfterDiscount, rate: $0) }
        } else {
            self.totalAmount = totalAmountAfterDiscount
            self.vat = vatRate.map { VatAmount(totalAmountBeforeVat: totalAmountAfterDiscount, rate: $0) }
        }
        
        // TacWithholding
        if let vat = self.vat {
            self.totalPayAmount = vat.amountAfterVat
            self.taxWithholding = taxWithholdingRate.map { TaxWithholding(totalAmount: vat.amountAfterVat, rate: $0) }
        } else {
            self.totalPayAmount = totalAmountAfterDiscount
            self.taxWithholding = taxWithholdingRate.map { TaxWithholding(totalAmount: totalAmountAfterDiscount, rate: $0) }
        }
        
        if let taxWithholding = self.taxWithholding {
            self.totalPayAmount = taxWithholding.amountAfterTaxWithholding
        }
    }
    
    convenience init(id: UUID? = nil,
                     itemId: UUID,
                     name: String,
                     description: String,
                     variant: ProductVariant?,
                     qty: Double,
                     pricePerUnitIncludeVat: Double,
                     discountPerUnit: Double = 0,
                     vatRate: Double?,
                     taxWithholdingRate: Double?) {
        self.init(id: id,
                  itemId: itemId,
                  name: name,
                  description: description,
                  variant: variant,
                  qty: qty,
                  pricePerUnit: pricePerUnitIncludeVat,
                  discountPerUnit: discountPerUnit,
                  vatRate: vatRate,
                  taxWithholdingRate: taxWithholdingRate,
                  isVatIncluded: true)
    }
    
    convenience init(id: UUID? = nil,
                     itemId: UUID,
                     name: String,
                     description: String,
                     variant: ProductVariant?,
                     qty: Double,
                     pricePerUnitExcludeVat: Double,
                     discountPerUnit: Double = 0,
                     vatRate: Double?,
                     taxWithholdingRate: Double?) {
        self.init(id: id,
                  itemId: itemId,
                  name: name,
                  description: description,
                  variant: variant,
                  qty: qty,
                  pricePerUnit: pricePerUnitExcludeVat,
                  discountPerUnit: discountPerUnit,
                  vatRate: vatRate,
                  taxWithholdingRate: taxWithholdingRate,
                  isVatIncluded: false)
    }
    
}

extension PurchaseOrderItem {
    enum Kind: String, Codable {
        case product = "PRODUCT"
        case service = "SERVICE"
    }
}

*/

/*
//
//  File.swift
//
//
//  Created by IntrodexMac on 4/6/2567 BE.
//

import Vapor
import Fluent

final class PurchaseOrderItem: Model, Content {
    static let schema = "PurchaseOrderItems"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "item_id")
    var itemId: UUID
    
    @Enum(key: "kind")
    var kind: Kind
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "variant")
    var variant: ProductVariant?
    
    @Field(key: "qty")
    var qty: Double
    
    @Field(key: "price_per_unit")
    var pricePerUnit: Double
    
    @Field(key: "discount_price_per_unit")
    var discountPricePerUnit: Double
    
    @Field(key: "total_discount_amount")
    var totalDiscountAmount: Double?
    
    @Field(key: "vat")
    var vat: VatAmount?
    
    @Field(key: "tax_withholding")
    var taxWithholding: TaxWithholding?
    
    @Field(key: "total_amount")
    var totalAmount: Double
    
    @Field(key: "total_pay_amount")
    var totalPayAmount: Double
    
    init() { }
    
    init(id: UUID? = nil,
         itemId: UUID,
         name: String,
         description: String,
         variant: ProductVariant?,
         qty: Double,
         pricePerUnit: Double,
         discountPerUnit: Double = 0,
         vatRate: Double?,
         taxWithholdingRate: Double?,
         isVatIncluded: Bool) {
        
        self.id = id
        self.itemId = itemId
        self.name = name
        self.description = description
        self.variant = variant
        self.qty = qty
        self.pricePerUnit = pricePerUnit
        self.discountPricePerUnit = discountPerUnit
        
        self.totalDiscountAmount = discountPerUnit * qty
        
        // Calculation part
        let rawTotalAmount = qty * pricePerUnit
        
        // Discount
        let totalAmountAfterDiscount = rawTotalAmount - (discountPerUnit * qty)
        
        // Vat
        if isVatIncluded {
            self.totalAmount = totalAmountAfterDiscount
            self.vat = vatRate.map { VatAmount(totalAmountIncludeVat: totalAmountAfterDiscount, rate: $0) }
        } else {
            self.totalAmount = totalAmountAfterDiscount
            self.vat = vatRate.map { VatAmount(totalAmountBeforeVat: totalAmountAfterDiscount, rate: $0) }
        }
        
        // TacWithholding
        if let vat = self.vat {
            self.totalPayAmount = vat.amountAfterVat
            self.taxWithholding = taxWithholdingRate.map { TaxWithholding(totalAmount: vat.amountAfterVat, rate: $0) }
        } else {
            self.totalPayAmount = totalAmountAfterDiscount
            self.taxWithholding = taxWithholdingRate.map { TaxWithholding(totalAmount: totalAmountAfterDiscount, rate: $0) }
        }
        
        if let taxWithholding = self.taxWithholding {
            self.totalPayAmount = taxWithholding.amountAfterTaxWithholding
        }
    }
    
    convenience init(id: UUID? = nil,
                     itemId: UUID,
                     name: String,
                     description: String,
                     variant: ProductVariant?,
                     qty: Double,
                     pricePerUnitIncludeVat: Double,
                     discountPerUnit: Double = 0,
                     vatRate: Double?,
                     taxWithholdingRate: Double?) {
        self.init(id: id,
                  itemId: itemId,
                  name: name,
                  description: description,
                  variant: variant,
                  qty: qty,
                  pricePerUnit: pricePerUnitIncludeVat,
                  discountPerUnit: discountPerUnit,
                  vatRate: vatRate,
                  taxWithholdingRate: taxWithholdingRate,
                  isVatIncluded: true)
    }
    
    convenience init(id: UUID? = nil,
                     itemId: UUID,
                     name: String,
                     description: String,
                     variant: ProductVariant?,
                     qty: Double,
                     pricePerUnitExcludeVat: Double,
                     discountPerUnit: Double = 0,
                     vatRate: Double?,
                     taxWithholdingRate: Double?) {
        self.init(id: id,
                  itemId: itemId,
                  name: name,
                  description: description,
                  variant: variant,
                  qty: qty,
                  pricePerUnit: pricePerUnitExcludeVat,
                  discountPerUnit: discountPerUnit,
                  vatRate: vatRate,
                  taxWithholdingRate: taxWithholdingRate,
                  isVatIncluded: false)
    }
    
}

extension PurchaseOrderItem {
    enum Kind: String, Codable {
        case product = "PRODUCT"
        case service = "SERVICE"
    }
}

struct VatAmount: Content {
    
    let amount: Double // vat amount
    let rate: Double // vat rate
    let amountBeforeVat: Double // total amount before vat
    let amountAfterVat: Double // total amount include vat
    
    // include vat
    init(totalAmountIncludeVat: Double,
         rate: Double = 0.07) {
        self.amount = totalAmountIncludeVat
        self.rate = rate
        self.amountBeforeVat = totalAmountIncludeVat / (1 + rate)
        self.amountAfterVat = totalAmountIncludeVat
    }
    
    // exclude vat
    init(totalAmountBeforeVat: Double,
         rate: Double = 0.07) {
        self.amount = totalAmountBeforeVat * rate
        self.rate = rate
        self.amountBeforeVat = totalAmountBeforeVat
        self.amountAfterVat = totalAmountBeforeVat * (1 + rate)
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Double.self,
                                           forKey: .amount)
        self.rate = try container.decode(Double.self,
                                         forKey: .rate)
        self.amountBeforeVat = try container.decode(Double.self,
                                                    forKey: .amountBeforeVat)
        self.amountAfterVat = try container.decode(Double.self,
                                                   forKey: .amountAfterVat)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(rate, forKey: .rate)
        try container.encode(amountBeforeVat, forKey: .amountBeforeVat)
        try container.encode(amountAfterVat, forKey: .amountAfterVat)
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case rate
        case amountBeforeVat = "amount_before_vat"
        case amountAfterVat = "amount_after_vat"
    }
    
}

struct TaxWithholding: Content {
    let amountBeforeTaxWithholding: Double // total amount before tax withholding
    let amount: Double // tax withholding amount
    let rate: Double // tax withholding rate
    let amountAfterTaxWithholding: Double // total amount after tax withholding
    
    //totalAmount can be 'total amount after vat' or 'total amount without vat'
    init(totalAmount: Double,
         rate: Double = 0.03) {
        self.amount = totalAmount * rate
        self.rate = rate
        self.amountBeforeTaxWithholding = totalAmount
        self.amountAfterTaxWithholding = totalAmount - (totalAmount * rate)
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Double.self,
                                           forKey: .amount)
        self.rate = try container.decode(Double.self,
                                         forKey: .rate)
        self.amountBeforeTaxWithholding = try container.decode(Double.self,
                                                              forKey: .amountBeforeTaxWithholding)
        self.amountAfterTaxWithholding = try container.decode(Double.self,
                                                              forKey: .amountAfterTaxWithholding)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(rate, forKey: .rate)
        try container.encode(amountBeforeTaxWithholding, forKey: .amountBeforeTaxWithholding)
        try container.encode(amountAfterTaxWithholding, forKey: .amountAfterTaxWithholding)
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case rate
        case amountBeforeTaxWithholding = "amount_before_tax_withholding"
        case amountAfterTaxWithholding = "amount_after_tax_withholding"
    }
}

*/
