//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class ServiceItem: Model, Content {
    static let schema: String = "ServiceItems"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "service_id")
    var serviceId: UUID
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "qty")
    var qty: Double
    
    @Field(key: "price_per_unit")
    var pricePerUnit: Double

    @Field(key: "discount_amount")
    var discountAmount: Double?

    @Field(key: "vat_amount")
    var vatAmount: VatAmount?        

    @Field(key: "total_price")
    var totalPrice: Double

    @Field(key: "tax_withholding")
    var taxWithholding: TaxWithholding?
    
    init() { }
    
    init(id: UUID? = nil,
            serviceId: UUID,
            name: String,
            description: String,
            qty: Double,
            pricePerUnit: Double,
            discountAmount: Double?,
            vatAmount: VatAmount?,
            totalPrice: Double,
            taxWithholding: TaxWithholding?) {
            self.id = id
            self.serviceId = serviceId
            self.name = name
            self.description = description
            self.qty = qty
            self.pricePerUnit = pricePerUnit
            self.discountAmount = discountAmount
            self.vatAmount = vatAmount
            self.totalPrice = totalPrice
            self.taxWithholding = taxWithholding
    }
    
}
