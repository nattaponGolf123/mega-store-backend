//
//  File.swift
//
//
//  Created by IntrodexMac on 23/6/2567 BE.
//

import Foundation

// Struct to represent an item/service in the bill
struct BillItem {
    var description: String
    var quantity: Double
    var pricePerUnit: Double
    var discountPerUnit: Double // Changed to discountPerUnit
    var vatRate: Double? // Optional tax rate
    var withholdingTaxRate: Double? // Optional withholding tax rate
    var vatIncluded: Bool // Boolean to indicate if unit price includes VAT
    
    init(description: String,
         quantity: Double,
         pricePerUnit: Double,
         discountPerUnit: Double,
         vatRate: Double? = nil,
         withholdingTaxRate: Double? = nil,
         vatIncluded: Bool) {
        self.description = description
        self.quantity = quantity
        self.pricePerUnit = pricePerUnit
        self.discountPerUnit = discountPerUnit
        self.vatRate = vatRate
        self.withholdingTaxRate = withholdingTaxRate
        self.vatIncluded = vatIncluded
    }
    
    // Computed properties for the item
    var basePricePerUnit: Double {
        if vatIncluded, let vatRate = vatRate {
            return pricePerUnit / (1 + vatRate)
        } else {
            return pricePerUnit
        }
    }
    
    var amountBeforeDiscount: Double {
        return quantity * basePricePerUnit
    }
    
    var baseDiscountPerUnit: Double {
        if vatIncluded, let vatRate = vatRate {
            return discountPerUnit / (1 + vatRate)
        } else {
            return discountPerUnit
        }
    }
    
    var amountDiscount: Double {
        return quantity * baseDiscountPerUnit
    }
    
//    var baseDiscount: Double {
//        if vatIncluded, let vatRate = vatRate {
//            return amountDiscount / (1 + vatRate)
//        } else {
//            return amountDiscount
//        }
//    }
    
    func amountBeforeVat(withAdditionalDiscount: Double = 0) -> Double {
        let baseDiscountAmount = baseDiscount(amount: withAdditionalDiscount,
                                              vatIncluded: self.vatIncluded,
                                              vatRate: self.vatRate)
        let totalDiscount = amountDiscount + baseDiscountAmount
        return amountBeforeDiscount - totalDiscount
    }
    
    func amountAfterVat(withAdditionalDiscount: Double = 0) -> Double {
        let amountBeforeVat = amountBeforeVat(withAdditionalDiscount: withAdditionalDiscount)
        let vatAmount = vatAmount(withAdditionalDiscount: withAdditionalDiscount)
        return amountBeforeVat + vatAmount
    }
    
    func vatAmount(withAdditionalDiscount: Double = 0) -> Double {
        if let vatRate = vatRate {
            return amountBeforeVat(withAdditionalDiscount: withAdditionalDiscount) * vatRate
        } else {
            return 0.0
        }
    }
    
    func withholdingTaxAmount(withAdditionalDiscount: Double = 0) -> Double {
        if let withholdingTaxRate = withholdingTaxRate {
            return amountBeforeVat(withAdditionalDiscount: withAdditionalDiscount) * withholdingTaxRate
        } else {
            return 0.0
        }
    }
    
    func amountDue(withAdditionalDiscount: Double = 0) -> Double {
        let amountAfterVat = amountAfterVat(withAdditionalDiscount: withAdditionalDiscount)
        let withholdingTax = withholdingTaxAmount(withAdditionalDiscount: withAdditionalDiscount)
        
        return amountAfterVat - withholdingTax
    }
    
    
    // helper
    func baseDiscount(amount: Double,
                      vatIncluded: Bool,
                      vatRate: Double?) -> Double {
        if vatIncluded, let vatRate = vatRate {
            return amount / (1 + vatRate)
        } else {
            return amount
        }
    }
}
