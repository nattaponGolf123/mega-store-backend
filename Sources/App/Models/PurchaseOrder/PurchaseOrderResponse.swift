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
    let supplier: ContactResponse?
    let customer: ContactResponse?
    
    let status: PurchaseOrderStatus
    
    let vatOption: PurchaseOrder.VatOption
    let includedVat: Bool
    
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
        supplier = ContactResponse(from: po.supplier!)
        customer = ContactResponse(from: po.customer!)
        status = po.status
        vatOption = po.vatOption
        includedVat = po.includedVat
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
    
    // enum CodingKeys with snake case string ex case itemId = "item_id"
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case reference
        case items
        case orderDate = "order_date"
        case deliveryDate = "delivery_date"
        case paymentTermsDays = "payment_terms_days"
        case supplier
        case customer
        case status
        case vatOption = "vat_option"
        case includedVat = "included_vat"
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
