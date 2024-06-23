import Foundation
import Vapor

struct Vat: Content {
    
    let amount: Double // vat amount
    let rate: Double // vat rate
    let amountBefore: Double // total amount before vat
    let amountAfter: Double // total amount include vat
    
    // include vat
    init(totalAmountIncludeVat: Double,
         rate: Double = 0.07) {
        let _amountBefore = totalAmountIncludeVat / (1 + rate)
        
        self.amount = totalAmountIncludeVat - _amountBefore
        self.rate = rate
        self.amountBefore = _amountBefore
        self.amountAfter = totalAmountIncludeVat
    }
    
    // exclude vat
    init(totalAmountExcludeVat: Double,
         rate: Double = 0.07) {
        self.amount = totalAmountExcludeVat * rate
        self.rate = rate
        self.amountBefore = totalAmountExcludeVat
        self.amountAfter = totalAmountExcludeVat * (1 + rate)
    }
    
    func applyDiscount(discountAmountExcludeVat: Double) -> Self {
        let newAmount = amountBefore - discountAmountExcludeVat
        return Vat(totalAmountExcludeVat: newAmount,
                   rate: rate)
    }
    
    func applyDiscount(discountAmountIncludeVat: Double) -> Self {
        let newAmount = amountAfter - discountAmountIncludeVat
        return Vat(totalAmountIncludeVat: newAmount,
                   rate: rate)
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
