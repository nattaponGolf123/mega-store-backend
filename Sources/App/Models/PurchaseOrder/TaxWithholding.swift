import Foundation
import Vapor

struct TaxWithholding: Content {
    let amountBefore: Double // total amount before tax withholding
    let amount: Double // tax withholding amount
    let rate: Double // tax withholding rate
    let amountAfter: Double // total amount after tax withholding
    
    //totalAmount can be 'total amount after vat' or 'total amount without vat'
    init(totalAmount: Double,
         rate: Double = 0.03) {  
        let _amount = totalAmount * rate
        
        self.amount = _amount
        self.rate = rate
        self.amountBefore = totalAmount
        self.amountAfter = totalAmount - _amount
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Double.self,
                                           forKey: .amount)
        self.rate = try container.decode(Double.self,
                                         forKey: .rate)
        self.amountBefore = try container.decode(Double.self,
                                                              forKey: .amountBefore)
        self.amountAfter = try container.decode(Double.self,
                                                              forKey: .amountAfter)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(rate, forKey: .rate)
        try container.encode(amountBefore, forKey: .amountBefore)
        try container.encode(amountAfter, forKey: .amountAfter)
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case rate
        case amountBefore = "amount_before"
        case amountAfter = "amount_after"
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
