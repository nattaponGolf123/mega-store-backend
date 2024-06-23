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
//        self.additionalDiscountAmount = Self.baseDiscount(amount: additionalDiscountAmount,
//                                                          vatIncluded: vatIncluded,
//                                                          vatRate: vatRate)
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
    
    var totalAmountDue: Double {
        return totalAmountAfterVat - totalWithholdingTaxAmount
    }
    
//
//    var totalDiscounts: Double {
//        let totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
//        return items.reduce(0) {            
//            return $0 + $1.baseDiscount + totalDiscountPerItem
//        }
//    }
//    
//    var totalAfterDiscounts: Double {
//        let totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
//        return items.reduce(0) { $0 + $1.amountBeforeVat(withAdditionalDiscount: totalDiscountPerItem) }
//    }
//    
//    var totalVat: Double {
//        let totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
//        return items.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: totalDiscountPerItem) }
//    }
//    
//    var totalAfterVat: Double {
//        return totalAfterDiscounts + totalVat
//    }
//        
//    var totalWithholdingTax: Double {
//        let totalDiscountPerItem = additionalDiscountAmount / Double(items.count)
//        return items.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: totalDiscountPerItem) }
//    }
//    
//    var totalPayable: Double {
//        return totalAfterVat - totalWithholdingTax
//    }
    
    // helper
    static func baseDiscount(amount: Double,
                      vatIncluded: Bool,
                      vatRate: Double?) -> Double {
        if vatIncluded, let vatRate = vatRate {
            return amount / (1 + vatRate)
        } else {
            return amount
        }
    }
}

//// Example usage
//let item1 = BillItem(description: "Service 1", quantity: 1.00, pricePerUnit: 107.00, discountPerUnit: 10.00, vatRate: 0.07, withholdingTaxRate: 0.03, vatIncluded: true)
//let item2 = BillItem(description: "Service 2", quantity: 1.00, pricePerUnit: 50.00, discountPerUnit: 5.00, vatRate: nil, withholdingTaxRate: nil, vatIncluded: false)
//
//let bill = BillSummary(items: [item1, item2], additionalDiscountAmount: 15.00)
//
//print("Total before discounts: \(bill.totalBeforeDiscounts)")
//print("Total discounts: \(bill.totalDiscounts)")
//print("Total after discounts: \(bill.totalAfterDiscounts)")
//print("Total tax: \(bill.totalVat)")
//print("Total withholding tax: \(bill.totalWithholdingTax)")
//print("Total amount: \(bill.totalAmount)")
//print("Total payable: \(bill.totalPayable)")
