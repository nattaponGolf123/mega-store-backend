import Foundation
import Vapor
import Fluent

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
    
    @Field(key: "qty")
    var qty: Double
    
    @Field(key: "price_per_unit")
    var pricePerUnit: Double

    @Field(key: "discount_amount")
    var discountAmount: Double?

    @Field(key: "vat")
    var vat: Vat?

    @Field(key: "total_price")
    var totalPrice: Double

    @Field(key: "tax_withholding")
    var taxWithholding: TaxWithholding?
    
    init() { }
    
    init(id: UUID? = nil,
            productId: UUID,
            name: String,
            description: String,
            variant: ProductVariant?,
            qty: Double,
            pricePerUnit: Double,
            discountAmount: Double?,
            vatAmount: Vat?,
            totalPrice: Double,
            taxWithholding: TaxWithholding?) {
            self.id = id
            self.productId = productId
            self.name = name
            self.description = description
            self.variant = variant
            self.qty = qty
            self.pricePerUnit = pricePerUnit
            self.discountAmount = discountAmount
            self.vat = vatAmount
            self.totalPrice = totalPrice
            self.taxWithholding = taxWithholding
        }
    
}
