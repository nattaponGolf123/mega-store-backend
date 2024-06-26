//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/6/2567 BE.
//

import Foundation
import Vapor

struct PurchaseOrderResponse: Content {
    let id: UUID
        
    let code: String
    
    let reference: String?
    let items: [PurchaseOrderItemResponse]
    let orderDate: Date
    let deliveryDate: Date
    let paymentTermsDays: Int
    let supplierId: UUID
    let customerId: UUID
    
    let status: PurchaseOrderStatus
    
    let vatOption: PurchaseOrder.VatOption
    let includedVat: Bool
    let vatRate: Double?
    
    let totalAmountBeforeDiscount: Double
    let totalAmountBeforeVat: Double
    let totalVatAmount: Double?
    let totalAmountAfterVat: Double
    let totalWithholdingTaxAmount: Double?
    let totalAmountDue: Double
    
    let additionalDiscountAmount: Double

    let currency: CurrencySupported
    let note: String
    
    let createdAt: Date?
    let updatedAt: Date?
    let pendedAt: Date?
    let approvedAt: Date?
    let voidedAt: Date?
    
    let logs: [ActionLog]
    
    init(po: PurchaseOrder) {
        id = po.id!
        code = PurchaseOrderCode(gregorianYear: po.year,
                                 month: po.month,
                                 number: po.number).code
        
        reference = po.reference
        items = po.items.map { PurchaseOrderItemResponse(item: $0) }
        orderDate = po.orderDate
        deliveryDate = po.deliveryDate
        paymentTermsDays = po.paymentTermsDays
        supplierId = po.supplierId
        customerId = po.customerId
        status = po.status
        vatOption = po.vatOption
        includedVat = po.includedVat
        vatRate = po.vatRate
        totalAmountBeforeDiscount = po.totalAmountBeforeDiscount
        totalAmountBeforeVat = po.totalAmountBeforeVat
        totalVatAmount = po.totalVatAmount
        totalAmountAfterVat = po.totalAmountAfterVat
        totalWithholdingTaxAmount = po.totalWithholdingTaxAmount
        totalAmountDue = po.totalAmountDue
        additionalDiscountAmount = po.additionalDiscountAmount
        currency = po.currency
        note = po.note
        createdAt = po.createdAt
        updatedAt = po.updatedAt
        pendedAt = po.pendedAt
        approvedAt = po.approvedAt
        voidedAt = po.voidedAt
        logs = po.logs
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(code, forKey: .code)
        try container.encode(reference, forKey: .reference)
        try container.encode(items, forKey: .items)
        try container.encode(orderDate, forKey: .orderDate)
        try container.encode(deliveryDate, forKey: .deliveryDate)
        try container.encode(paymentTermsDays, forKey: .paymentTermsDays)
        try container.encode(supplierId, forKey: .supplierId)
        try container.encode(customerId, forKey: .customerId)
        try container.encode(status, forKey: .status)
        try container.encode(vatOption, forKey: .vatOption)
        try container.encode(includedVat, forKey: .includedVat)
        try container.encode(vatRate, forKey: .vatRate)
        try container.encode(totalAmountBeforeDiscount, forKey: .totalAmountBeforeDiscount)
        try container.encode(totalAmountBeforeVat, forKey: .totalAmountBeforeVat)
        try container.encode(totalVatAmount, forKey: .totalVatAmount)
        try container.encode(totalAmountAfterVat, forKey: .totalAmountAfterVat)
        try container.encode(totalWithholdingTaxAmount, forKey: .totalWithholdingTaxAmount)
        try container.encode(totalAmountDue, forKey: .totalAmountDue)
        try container.encode(additionalDiscountAmount, forKey: .additionalDiscountAmount)
        try container.encode(currency, forKey: .currency)
        try container.encode(note, forKey: .note)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(pendedAt, forKey: .pendedAt)
        try container.encode(approvedAt, forKey: .approvedAt)
        try container.encode(voidedAt, forKey: .voidedAt)
        try container.encode(logs, forKey: .logs)
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        reference = try container.decode(String?.self, forKey: .reference)
        items = try container.decode([PurchaseOrderItemResponse].self, forKey: .items)
        orderDate = try container.decode(Date.self, forKey: .orderDate)
        deliveryDate = try container.decode(Date.self, forKey: .deliveryDate)
        paymentTermsDays = try container.decode(Int.self, forKey: .paymentTermsDays)
        supplierId = try container.decode(UUID.self, forKey: .supplierId)
        customerId = try container.decode(UUID.self, forKey: .customerId)
        status = try container.decode(PurchaseOrderStatus.self, forKey: .status)
        vatOption = try container.decode(PurchaseOrder.VatOption.self, forKey: .vatOption)
        includedVat = try container.decode(Bool.self, forKey: .includedVat)
        vatRate = try container.decode(Double?.self, forKey: .vatRate)
        totalAmountBeforeDiscount = try container.decode(Double.self, forKey: .totalAmountBeforeDiscount)
        totalAmountBeforeVat = try container.decode(Double.self, forKey: .totalAmountBeforeVat)
        totalVatAmount = try container.decode(Double?.self, forKey: .totalVatAmount)
        totalAmountAfterVat = try container.decode(Double.self, forKey: .totalAmountAfterVat)
        totalWithholdingTaxAmount = try container.decode(Double?.self, forKey: .totalWithholdingTaxAmount)
        totalAmountDue = try container.decode(Double.self, forKey: .totalAmountDue)
        additionalDiscountAmount = try container.decode(Double.self, forKey: .additionalDiscountAmount)
        currency = try container.decode(CurrencySupported.self, forKey: .currency)
        note = try container.decode(String.self, forKey: .note)
        createdAt = try container.decode(Date?.self, forKey: .createdAt)
        updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        pendedAt = try container.decode(Date?.self, forKey: .pendedAt)
        approvedAt = try container.decode(Date?.self, forKey: .approvedAt)
        voidedAt = try container.decode(Date?.self, forKey: .voidedAt)
        logs = try container.decode([ActionLog].self, forKey: .logs)
    }
    
    // enum CodingKeys with snake case string ex case itemId = "item_id"
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case reference
        case items
        case orderDate = "order_date"
        case deliveryDate = "delivery_date"
        case paymentTermsDays = "payment_terms_days"
        case supplierId = "supplier_id"
        case customerId = "customer_id"
        case status
        case vatOption = "vat_option"
        case includedVat = "included_vat"
        case vatRate = "vat_rate"
        case totalAmountBeforeDiscount = "total_amount_before_discount"
        case totalAmountBeforeVat = "total_amount_before_vat"
        case totalVatAmount = "total_vat_amount"
        case totalAmountAfterVat = "total_amount_after_vat"
        case totalWithholdingTaxAmount = "total_withholding_tax_amount"
        case totalAmountDue = "total_amount_due"
        case additionalDiscountAmount = "additional_discount_amount"
        case currency
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pendedAt = "pended_at"
        case approvedAt = "approved_at"
        case voidedAt = "voided_at"
        case logs
    }
}
