import Foundation
import Vapor
import Fluent

protocol ListItemProtocol {
    var id: UUID? { get }
    var kind: ListItemKind { get }
    var name: String { get }
    var description: String { get }
    var quantity: Double { get }
    var price: Double { get }
    var totalPrice: Double { get }
    var unit: String { get }
    var remark: String { get }
}

enum ListItemKind: String, Codable {
    case product
    case service
}

final class ProductItem: Model, Content {
    static let schema = "ProductItems"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "product_id")
    var productId: UUID
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "variant")
    var variant: ProductVariant?
    
    @Field(key: "quantity")
    var quantity: Double
    
    @Field(key: "selling_price")
    var sellingPrice: Double
    
    @Field(key: "total_price")
    var totalPrice: Double
    
    @Field(key: "unit")
    var unit: String
    
    @Field(key: "remark")
    var remark: String
    
    init() { }
    
    init(id: UUID? = nil,
         productId: UUID,
         name: String,
         description: String = "",
         variant: ProductVariant? = nil,
         quantity: Double = 1.0,
         sellingPrice: Double = 0.0,
         unit: String = "",
         remark: String = "") {
        self.id = id ?? .init()
        self.productId = productId
        self.name = name
        self.description = description
        self.variant = variant
        self.quantity = quantity
        self.sellingPrice = sellingPrice
        self.totalPrice = quantity * sellingPrice
        self.unit = unit
        self.remark = remark
    }
    
}
