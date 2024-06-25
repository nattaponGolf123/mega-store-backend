//
//  File.swift
//  
//
//  Created by IntrodexMac on 25/6/2567 BE.
//

import Foundation
import Vapor

struct PurchaseOrderItemResponse: Content {
    let id: UUID
    let itemId: UUID
    let kind: PurchaseOrderItem.Kind
    
    let name: String
    let description: String
    let variantId: UUID?
    
    let qty: Double
    let pricePerUnit: Double
    let discountPricePerUnit: Double
    let additionalDiscount: Double
    
    let baseDiscountPerUnit: Double
    let amountDiscount: Double
    
    let vatRate: Double?
    let vatIncluded: Bool
    let taxWithholdingRate: Double?
    
    let amountBeforeVat: Double
    let amountAfterVat: Double
    let vatAmount: Double?
    let withholdingTaxAmount: Double?
    let amountDue: Double
    
    init(item: PurchaseOrderItem) {
        self.id = item.id ?? .init()
        self.itemId = item.itemId
        self.kind = item.kind
        self.name = item.name
        self.description = item.description
        self.variantId = item.variantId
        self.qty = item.qty
        self.pricePerUnit = item.pricePerUnit
        self.discountPricePerUnit = item.discountPricePerUnit
        self.additionalDiscount = item.additionalDiscount
        self.baseDiscountPerUnit = item.baseDiscountPerUnit
        self.amountDiscount = item.amountDiscount
        self.vatRate = item.vatRate
        self.vatIncluded = item.vatIncluded
        self.taxWithholdingRate = item.taxWithholdingRate
        self.amountBeforeVat = item.amountBeforeVat
        self.amountAfterVat = item.amountAfterVat
        self.vatAmount = item.vatAmount
        self.withholdingTaxAmount = item.withholdingTaxAmount
        self.amountDue = item.amountDue
    }
    
    // encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(kind, forKey: .kind)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(variantId, forKey: .variantId)
        try container.encode(qty, forKey: .qty)
        try container.encode(pricePerUnit, forKey: .pricePerUnit)
        try container.encode(discountPricePerUnit, forKey: .discountPricePerUnit)
        try container.encode(additionalDiscount, forKey: .additionalDiscount)
        try container.encode(baseDiscountPerUnit, forKey: .baseDiscountPerUnit)
        try container.encode(amountDiscount, forKey: .amountDiscount)
        try container.encode(vatRate, forKey: .vatRate)
        try container.encode(vatIncluded, forKey: .vatIncluded)
        try container.encode(taxWithholdingRate, forKey: .taxWithholdingRate)
        try container.encode(amountBeforeVat, forKey: .amountBeforeVat)
        try container.encode(amountAfterVat, forKey: .amountAfterVat)
        try container.encode(vatAmount, forKey: .vatAmount)
        try container.encode(withholdingTaxAmount, forKey: .withholdingTaxAmount)
        try container.encode(amountDue, forKey: .amountDue)
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        itemId = try container.decode(UUID.self, forKey: .itemId)
        kind = try container.decode(PurchaseOrderItem.Kind.self, forKey: .kind)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        variantId = try container.decode(UUID.self, forKey: .variantId)
        qty = try container.decode(Double.self, forKey: .qty)
        pricePerUnit = try container.decode(Double.self, forKey: .pricePerUnit)
        discountPricePerUnit = try container.decode(Double.self, forKey: .discountPricePerUnit)
        additionalDiscount = try container.decode(Double.self, forKey: .additionalDiscount)
        baseDiscountPerUnit = try container.decode(Double.self, forKey: .baseDiscountPerUnit)
        amountDiscount = try container.decode(Double.self, forKey: .amountDiscount)
        vatRate = try container.decode(Double.self, forKey: .vatRate)
        vatIncluded = try container.decode(Bool.self, forKey: .vatIncluded)
        taxWithholdingRate = try container.decode(Double.self, forKey: .taxWithholdingRate)
        amountBeforeVat = try container.decode(Double.self, forKey: .amountBeforeVat)
        amountAfterVat = try container.decode(Double.self, forKey: .amountAfterVat)
        vatAmount = try container.decode(Double.self, forKey: .vatAmount)
        withholdingTaxAmount = try container.decode(Double.self, forKey: .withholdingTaxAmount)
        amountDue = try container.decode(Double.self, forKey: .amountDue)
    }
    
    //enum
    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case kind
        case name
        case description
        case variantId = "variant_id"
        case qty
        case pricePerUnit = "price_per_unit"
        case discountPricePerUnit = "discount_price_per_unit"
        case additionalDiscount = "additional_discount"
        case baseDiscountPerUnit = "base_discount_per_unit"
        case amountDiscount = "amount_discount"
        case vatRate = "vat_rate"
        case vatIncluded = "vat_included"
        case taxWithholdingRate = "tax_withholding_rate"
        case amountBeforeVat = "amount_before_vat"
        case amountAfterVat = "amount_after_vat"
        case vatAmount = "vat_amount"
        case withholdingTaxAmount = "withholding_tax_amount"
        case amountDue = "amount_due"
    }
}
