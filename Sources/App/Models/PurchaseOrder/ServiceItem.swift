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
    
    @Field(key: "quantity")
    var quantity: Double
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "total_price")
    var totalPrice: Double
    
    @Field(key: "unit")
    var unit: String
    
    @Field(key: "remark")
    var remark: String
    
    init() { }
    
    init(id: UUID? = nil,
         serviceId: UUID,
         name: String,
         description: String = "",
         quantity: Double = 1.0,
         price: Double = 0.0,         
         unit: String = "",
         remark: String = "") {
        self.id = id ?? .init()
        self.serviceId = serviceId
        self.name = name
        self.description = description
        self.quantity = quantity
        self.price = price
        self.totalPrice = quantity * price
        self.unit = unit
        self.remark = remark
    }
    
}
