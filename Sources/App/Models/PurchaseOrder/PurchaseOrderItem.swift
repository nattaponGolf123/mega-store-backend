//
//  File.swift
//
//
//  Created by IntrodexMac on 4/6/2567 BE.
//

import Vapor
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
    var itemName: String
    
    @Field(key: "description")
    var itemDescription: String
    
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
    
    @Field(key: "vat_rate_option")
    var vatRateOption: VatRateOption
    
    @Field(key: "vat_included")
    var vatIncluded: Bool
    
    @Field(key: "tax_withholding_rate")
    var taxWithholdingRate: Double?
    
    @Field(key: "tax_withholding_rate_option")
    var taxWithholdingRateOption: TaxWithholdingRateOption
    
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
    
    init(id: UUID? = nil,
         itemId: UUID,
         kind: Kind,
         itemName: String,
         itemDescription: String,
         variantId: UUID? = nil,
         qty: Double,
         pricePerUnit: Double,
         discountPricePerUnit: Double,
         additionalDiscount: Double,
         vatRateOption: VatRateOption,
         vatIncluded: Bool,
         taxWithholdingRateOption: TaxWithholdingRateOption) {
        self.id = id ?? .init()
        self.itemId = itemId
        self.kind = kind
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.variantId = variantId
        self.qty = qty
        self.pricePerUnit = pricePerUnit
        self.discountPricePerUnit = discountPricePerUnit
        
        self.vatRate = vatRateOption.value
        self.vatRateOption = vatRateOption
        self.vatIncluded = vatIncluded
        self.taxWithholdingRate = taxWithholdingRateOption.value
        self.taxWithholdingRateOption = taxWithholdingRateOption
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
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.itemId = try container.decode(UUID.self, forKey: .itemId)
        self.kind = try container.decode(Kind.self, forKey: .kind)
        self.itemName = try container.decode(String.self, forKey: .itemName)
        self.itemDescription = try container.decode(String.self, forKey: .itemDescription)
        self.variantId = try container.decodeIfPresent(UUID.self, forKey: .variantId)
        self.qty = try container.decode(Double.self, forKey: .qty)
        self.pricePerUnit = try container.decode(Double.self, forKey: .pricePerUnit)
        self.discountPricePerUnit = try container.decode(Double.self, forKey: .discountPricePerUnit)
        self.additionalDiscount = try container.decode(Double.self, forKey: .additionalDiscount)
        self.baseDiscountPerUnit = try container.decode(Double.self, forKey: .baseDiscountPerUnit)
        self.amountDiscount = try container.decode(Double.self, forKey: .amountDiscount)
        self.vatRate = try container.decodeIfPresent(Double.self, forKey: .vatRate)
        self.vatRateOption = try container.decode(VatRateOption.self, forKey: .vatRateOption)
        self.vatIncluded = try container.decode(Bool.self, forKey: .vatIncluded)
        self.taxWithholdingRate = try container.decodeIfPresent(Double.self, forKey: .taxWithholdingRate)
        self.taxWithholdingRateOption = try container.decode(TaxWithholdingRateOption.self, forKey: .taxWithholdingRateOption)
        self.amountBeforeVat = try container.decode(Double.self, forKey: .amountBeforeVat)
        self.amountAfterVat = try container.decode(Double.self, forKey: .amountAfterVat)
        self.vatAmount = try container.decodeIfPresent(Double.self, forKey: .vatAmount)
        self.withholdingTaxAmount = try container.decodeIfPresent(Double.self, forKey: .withholdingTaxAmount)
        self.amountDue = try container.decode(Double.self, forKey: .amountDue)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(kind, forKey: .kind)
        try container.encode(itemName, forKey: .itemName)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encodeIfPresent(variantId, forKey: .variantId)
        try container.encode(qty, forKey: .qty)
        try container.encode(pricePerUnit, forKey: .pricePerUnit)
        try container.encode(discountPricePerUnit, forKey: .discountPricePerUnit)
        try container.encode(additionalDiscount, forKey: .additionalDiscount)
        try container.encode(baseDiscountPerUnit, forKey: .baseDiscountPerUnit)
        try container.encode(amountDiscount, forKey: .amountDiscount)
        try container.encode(vatRate, forKey: .vatRate)
        try container.encode(vatRateOption, forKey: .vatRateOption)
        try container.encode(vatIncluded, forKey: .vatIncluded)
        try container.encode(taxWithholdingRate, forKey: .taxWithholdingRate)
        try container.encode(taxWithholdingRateOption, forKey: .taxWithholdingRateOption)
        try container.encode(amountBeforeVat, forKey: .amountBeforeVat)
        try container.encode(amountAfterVat, forKey: .amountAfterVat)
        try container.encodeIfPresent(vatAmount, forKey: .vatAmount)
        try container.encodeIfPresent(withholdingTaxAmount, forKey: .withholdingTaxAmount)
        try container.encode(amountDue, forKey: .amountDue)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case kind
        case itemName = "item_name"
        case itemDescription = "item_description"
        case variantId = "variant_id"
        case qty
        case pricePerUnit = "price_per_unit"
        case discountPricePerUnit = "discount_price_per_unit"
        case additionalDiscount = "additional_discount"
        case baseDiscountPerUnit = "base_discount_per_unit"
        case amountDiscount = "amount_discount"
        case vatRate = "vat_rate"
        case vatRateOption = "vat_rate_option"
        case vatIncluded = "vat_included"
        case taxWithholdingRate = "tax_withholding_rate"
        case taxWithholdingRateOption = "tax_withholding_rate_option"
        case amountBeforeVat = "amount_before_vat"
        case amountAfterVat = "amount_after_vat"
        case vatAmount = "vat_amount"
        case withholdingTaxAmount = "withholding_tax_amount"
        case amountDue = "amount_due"
    }
}

extension PurchaseOrderItem {
    enum Kind: String, Codable {
        case product = "PRODUCT"
        case service = "SERVICE"
    }
}
