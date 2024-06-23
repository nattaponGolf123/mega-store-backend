//
//  File.swift
//
//
//  Created by IntrodexMac on 4/6/2567 BE.
//

import Vapor
import Fluent

struct PurchaseOrderItem: Content {
    var id: UUID?
    var itemId: UUID
    var kind: Kind
    
    var name: String
    var description: String
    var variant: ProductVariant?
    
    var qty: Double
    var pricePerUnit: Double
    var discountPricePerUnit: Double
    var additionalDiscount: Double
    
    var baseDiscountPerUnit: Double
    var amountDiscount: Double
    
    var vatRate: Double?
    var vatIncluded: Bool
    var taxWithholdingRate: Double?
    
    var amountBeforeVat: Double
    var amountAfterVat: Double
    var vatAmount: Double?
    var withholdingTaxAmount: Double?
    var amountDue: Double
    
    
    init(id: UUID? = nil, 
         itemId: UUID,
         kind: Kind,
         name: String,
         description: String,
         variant: ProductVariant? = nil,
         qty: Double,
         pricePerUnit: Double,
         discountPricePerUnit: Double,
         additionalDiscount: Double,
         vatRate: Double? = nil,
         vatIncluded: Bool,
         taxWithholdingRate: Double? = nil) {
        self.id = id
        self.itemId = itemId
        self.kind = kind
        self.name = name
        self.description = description
        self.variant = variant
        self.qty = qty
        self.pricePerUnit = pricePerUnit
        self.discountPricePerUnit = discountPricePerUnit
        
        self.vatRate = vatRate
        self.vatIncluded = vatIncluded
        self.taxWithholdingRate = taxWithholdingRate
        self.additionalDiscount = additionalDiscount
        
        let item = BillItem(description: description,
                            quantity: qty,
                            pricePerUnit: pricePerUnit,
                            discountPerUnit: discountPricePerUnit,
                            vatRate: vatRate,
                            withholdingTaxRate: taxWithholdingRate,
                            vatIncluded: vatIncluded)
        
        self.baseDiscountPerUnit = item.baseDiscountPerUnit
        self.amountDiscount = item.amountDiscount
        self.amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        self.amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        self.vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        self.withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        self.amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
    }
}

extension PurchaseOrderItem {
    enum Kind: String, Codable {
        case product = "PRODUCT"
        case service = "SERVICE"
    }
}


//final class PurchaseOrderItem: Model, Content {
//    static let schema = "PurchaseOrderItems"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Field(key: "item_id")
//    var itemId: UUID
//    
//    @Enum(key: "kind")
//    var kind: Kind
//    
//    @Field(key: "name")
//    var name: String
//    
//    @Field(key: "description")
//    var description: String
//    
//    @Field(key: "variant")
//    var variant: ProductVariant?
//    
//    @Field(key: "qty")
//    var qty: Double
//    
//    @Field(key: "price_per_unit")
//    var pricePerUnit: Double
//    
//    @Field(key: "discount_price_per_unit")
//    var discountPricePerUnit: Double
//    
//    @Field(key: "total_discount_amount")
//    var totalDiscountAmount: Double
//    
//    @Field(key: "vat")
//    var vat: Vat?
//    
//    @Field(key: "tax_withholding")
//    var taxWithholding: TaxWithholding?
//    
//    @Field(key: "total_amount")
//    var totalAmount: Double
//    
//    @Field(key: "total_pay_amount")
//    var totalPayAmount: Double
//    
//    init() { }
//    
//    init(id: UUID? = nil,
//         itemId: UUID,
//         name: String,
//         description: String,
//         variant: ProductVariant?,
//         qty: Double,
//         pricePerUnit: Double,
//         discountPerUnit: Double = 0,
//         vatRate: Double?,
//         taxWithholdingRate: Double?,
//         isVatIncluded: Bool) {
//        
//        self.id = id
//        self.itemId = itemId
//        self.name = name
//        self.description = description
//        self.variant = variant
//        self.qty = qty
//        self.pricePerUnit = pricePerUnit
//        self.discountPricePerUnit = discountPerUnit
//        
//        self.totalDiscountAmount = discountPerUnit * qty
//        
//        // Calculation part
//        let totalAmountBeforeDiscount = pricePerUnit * qty
//        let totalAmountDiscount: Double = discountPerUnit * qty
//
//        let totalAmountAfterDiscount = totalAmountBeforeDiscount - totalAmountDiscount
//        
//        // Vat
//        if isVatIncluded {            
//            self.vat = vatRate.map { Vat(totalAmountIncludeVat: totalAmountAfterDiscount, rate: $0) }            
//        } else {            
//            self.vat = vatRate.map { Vat(totalAmountExcludeVat: totalAmountAfterDiscount, rate: $0) }            
//        }
//
//        self.totalAmount = self.vat?.amountAfter ?? totalAmountAfterDiscount
//        
//        // TaxWithholding
//        if let vat = self.vat {
//            self.totalPayAmount = vat.amountAfter
//            self.taxWithholding = taxWithholdingRate.map {
//                .init(vat: vat, rate: $0)
//            }
//        } else {
//            self.totalPayAmount = totalAmountAfterDiscount
//            self.taxWithholding = taxWithholdingRate.map {
//                .init(totalAmount: totalAmountAfterDiscount, rate: $0)
//            }
//        }
//        
//        if let taxWithholding = self.taxWithholding {
//            self.totalPayAmount = taxWithholding.amountAfter
//        }
//    }
//    
//    convenience init(id: UUID? = nil,
//                     itemId: UUID,
//                     name: String,
//                     description: String,
//                     variant: ProductVariant?,
//                     qty: Double,
//                     pricePerUnitIncludeVat: Double,
//                     discountPerUnit: Double = 0,
//                     vatRate: Double?,
//                     taxWithholdingRate: Double?) {
//        self.init(id: id,
//                  itemId: itemId,
//                  name: name,
//                  description: description,
//                  variant: variant,
//                  qty: qty,
//                  pricePerUnit: pricePerUnitIncludeVat,
//                  discountPerUnit: discountPerUnit,
//                  vatRate: vatRate,
//                  taxWithholdingRate: taxWithholdingRate,
//                  isVatIncluded: true)
//    }
//    
//    convenience init(id: UUID? = nil,
//                     itemId: UUID,
//                     name: String,
//                     description: String,
//                     variant: ProductVariant?,
//                     qty: Double,
//                     pricePerUnitExcludeVat: Double,
//                     discountPerUnit: Double = 0,
//                     vatRate: Double?,
//                     taxWithholdingRate: Double?) {
//        self.init(id: id,
//                  itemId: itemId,
//                  name: name,
//                  description: description,
//                  variant: variant,
//                  qty: qty,
//                  pricePerUnit: pricePerUnitExcludeVat,
//                  discountPerUnit: discountPerUnit,
//                  vatRate: vatRate,
//                  taxWithholdingRate: taxWithholdingRate,
//                  isVatIncluded: false)
//    }
//    
//}
//
//extension PurchaseOrderItem {
//    enum Kind: String, Codable {
//        case product = "PRODUCT"
//        case service = "SERVICE"
//    }
//}
