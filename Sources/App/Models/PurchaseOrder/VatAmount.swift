import Foundation
import Vapor

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

/*
 {
 "total_amount": 1098.50, // total amount include vat
 "vat" : {
 "amount": 98.50, // vat amount or null
 "rate": 0.07,	  
 "amount_before_vat": 1098.50, // total amount before vat or null
 },
 "tax_withholding" : {
 "amount" : 32.95, // tax withholding amount or null
 "rate" : 0.03,
 "amount_after_tax_withholding" : 1065.55, // total amount after tax withholding or null
 },
 "currency": "THB",
 }
 */
