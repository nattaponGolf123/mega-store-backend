//
//  File.swift
//  
//
//  Created by IntrodexMac on 23/6/2567 BE.
//

import Foundation

// Struct to represent the summary of the bill
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
