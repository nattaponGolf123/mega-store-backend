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
    
    init(items: [BillItem],
         additionalDiscountAmount: Double = 0,
         vatRate: Double? = nil,
         vatIncluded: Bool) {
        self.items = items
        self.additionalDiscountAmount = additionalDiscountAmount
        self.totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
    }
       
    var totalAmountBeforeDiscount: Double {
        return items.reduce(0) { $0 + $1.amountBeforeDiscount }
    }
    
    var totalAmountBeforeVat: Double {
        return items.reduce(0) { $0 + $1.amountBeforeVat(withAdditionalDiscount: totalDiscountPerItem) }
    }
        
    var totalAmountAfterVat: Double {
        return items.reduce(0) { $0 + $1.amountAfterVat(withAdditionalDiscount: totalDiscountPerItem) }
    }
    
    var totalVatAmount: Double {
        return items.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: totalDiscountPerItem) }
    }
    
    var totalWithholdingTaxAmount: Double {
        return items.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: totalDiscountPerItem) }
    }
    
    //totalPayable
    var totalAmountDue: Double {
        return totalAmountAfterVat - totalWithholdingTaxAmount
    }
    
}
