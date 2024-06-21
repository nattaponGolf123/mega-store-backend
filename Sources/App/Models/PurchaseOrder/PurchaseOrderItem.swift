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
