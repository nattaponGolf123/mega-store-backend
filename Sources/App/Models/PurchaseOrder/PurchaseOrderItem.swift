//
//  File.swift
//
//
//  Created by IntrodexMac on 4/6/2567 BE.
//

import Vapor
import Fluent
import Fluent

final class PurchaseOrderItem: Model, Content {
    static var schema = "PurchaseOrderItem"
    
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
    
    @Field(key: "variant_id")
    var variantId: UUID?
    
    @Field(key: "qty")
    var qty: Double
    
    @Field(key: "price_per_unit")
    var pricePerUnit: Double
    
    @Field(key: "discount_price_per_unit")
    var discountPricePerUnit: Double
    
    @Field(key: "additional_discount")
    var additionalDiscount: Double
    
    @Field(key: "base_discount_per_unit")
    var baseDiscountPerUnit: Double
    
    @Field(key: "amount_discount")
    var amountDiscount: Double
    
    @Field(key: "vat_rate")
    var vatRate: Double?
    
    @Field(key: "vat_included")
    var vatIncluded: Bool
    
    @Field(key: "tax_withholding_rate")
    var taxWithholdingRate: Double?
    
    @Field(key: "amount_before_vat")
    var amountBeforeVat: Double
    
    @Field(key: "amount_after_vat")
    var amountAfterVat: Double
    
    @Field(key: "vat_amount")
    var vatAmount: Double?
    
    @Field(key: "withholding_tax_amount")
    var withholdingTaxAmount: Double?
    
    @Field(key: "amount_due")
    var amountDue: Double
    
    init() {
        
    }
    
    init(id: UUID?,
         itemId: UUID,
         kind: Kind,
         name: String,
         description: String,
         variantId: UUID? = nil,
         qty: Double,
         pricePerUnit: Double,
         discountPricePerUnit: Double,
         additionalDiscount: Double,
         vatRate: VatRate,
         vatIncluded: Bool,
         taxWithholdingRate: TaxWithholdingRate) {
        self.id = id
        self.itemId = itemId
        self.kind = kind
        self.name = name
        self.description = description
        self.variantId = variantId
        self.qty = qty
        self.pricePerUnit = pricePerUnit
        self.discountPricePerUnit = discountPricePerUnit
        
        self.vatRate = vatRate.value
        self.vatIncluded = vatIncluded
        self.taxWithholdingRate = taxWithholdingRate.value
        self.additionalDiscount = additionalDiscount
        
        let item = BillItem(description: description,
                            quantity: qty,
                            pricePerUnit: pricePerUnit,
                            discountPerUnit: discountPricePerUnit,
                            vatRate: self.vatRate,
                            withholdingTaxRate: self.taxWithholdingRate,
                            vatIncluded: vatIncluded)
        
        self.baseDiscountPerUnit = item.baseDiscountPerUnit
        self.amountDiscount = item.amountDiscount
        self.amountBeforeVat = item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
        self.amountAfterVat = item.amountAfterVat(withAdditionalDiscount: additionalDiscount)
        self.vatAmount = item.vatAmount(withAdditionalDiscount: additionalDiscount)
        self.withholdingTaxAmount = item.withholdingTaxAmount(withAdditionalDiscount: additionalDiscount)
        self.amountDue = item.amountDue(withAdditionalDiscount: additionalDiscount)
    }
    
    //encode
//    enum CodingKeys: String, CodingKey {
//        case id
//        case itemId = "item_id"
//        case kind
//        case name
//        case description
//        case variantId = "variant_id"
//        case qty
//        case pricePerUnit = "price_per_unit"
//        case discountPricePerUnit = "discount_price_per_unit"
//        case additionalDiscount = "additional_discount"
//        case baseDiscountPerUnit = "base_discount_per_unit"
//        case amountDiscount = "amount_discount"
//        case vatRate = "vat_rate"
//        case vatIncluded = "vat_included"
//        case taxWithholdingRate = "tax_withholding_rate"
//        case amountBeforeVat = "amount_before_vat"
//        case amountAfterVat = "amount_after_vat"
//        case vatAmount = "vat_amount"
//        case withholdingTaxAmount = "withholding_tax_amount"
//        case amountDue = "amount_due"
//    }
}

extension PurchaseOrderItem {
    enum Kind: String, Codable {
        case product = "PRODUCT"
        case service = "SERVICE"
    }
}
