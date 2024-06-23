import Foundation
import Vapor
import Fluent

// statuc flow : draft -> pending
// statuc flow : draft -> voided
// status flow : pending -> approved -> voided
// status flow : pending -> voided
enum PurchaseOrderStatus: String, Codable {
    case draft
    case pending
    case approved
    case rejected
    case voided
}

final class PurchaseOrder: Model, Content {
    static let schema = "PurchaseOrders"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "month")
    var month: Int
    
    @Field(key: "year")
    var year: Int
    
    @Field(key: "number")
    var number: Int
    
    @Field(key: "reference")
    var reference: String?
    
    @Field(key: "items")
    var items: [PurchaseOrderItem]
    
    @Field(key: "order_date")
    var orderDate: Date
    
    @Field(key: "delivery_date")
    var deliveryDate: Date
    
    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int
    
    @Field(key: "supplier_id")
    var supplierId: UUID
    
    @Field(key: "customer_id")
    var customerId: UUID
    
    @Field(key: "status")
    var status: PurchaseOrderStatus
    
    @Enum(key: "vat_option")
    var vatOption: VatOption
    
    // includedVat
    @Field(key: "included_vat")
    var includedVat: Bool
    
    //vat_rate
    @Field(key: "vat_rate")
    var vatRate: Double?
    
    //totalAmountBeforeDiscount
    @Field(key: "total_amount_before_discount")
    var totalAmountBeforeDiscount: Double
    
    //totalAmountBeforeVat
    @Field(key: "total_amount_before_vat")
    var totalAmountBeforeVat: Double
    
    //totalVatAmount
    @Field(key: "total_vat_amount")
    var totalVatAmount: Double?
    
    //totalAmountAfterVat
    @Field(key: "total_amount_after_vat")
    var totalAmountAfterVat: Double
    
    //totalWithholdingTaxAmount
    @Field(key: "total_withholding_tax_amount")
    var totalWithholdingTaxAmount: Double?
    
    //totalAmountDue
    @Field(key: "total_amount_due")
    var totalAmountDue: Double
    
    // sum(pricePerUnit x qty)
//    @Field(key: "total_amount")
//    var totalAmount: Double
//    
    @Field(key: "additional_discount_amount")
    var additionalDiscountAmount: Double
//    
//    // sum(discountPerUnit x qty) +
//    @Field(key: "total_discount_amount")
//    var totalDiscountAmount: Double
//    
//    // MARK: VAT
//    @Field(key: "vat_amount")
//    var vatAmount: Double?
//    
//    @Field(key: "vat_amount_before")
//    var vatAmountBefore: Double?
//    
//    @Field(key: "vat_amount_after")
//    var vatAmountAfter: Double?
//    
//    // MARK: TAX WITHHOLDING
//    @Field(key: "tax_withholding_amount")
//    var taxWithholdingAmount: Double?
//    
//    @Field(key: "tax_withholding_amount_before")
//    var taxWithholdingAmountBefore: Double?
//    
//    @Field(key: "tax_withholding_amount_after")
//    var taxWithholdingAmountAfter: Double?
//    
//    @Field(key: "payment_amount")
//    var paymentAmount: Double
    
    @Field(key: "currency")
    var currency: String
    
    @Field(key: "internal_note")
    var note: String
    
    @Timestamp(key: "created_at",
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?
    
    @Field(key: "pended_at")
    var pendedAt: Date?
    
    @Timestamp(key: "approved_at",
               on: .create,
               format: .iso8601)
    var approvedAt: Date?
    
    @Timestamp(key: "voided_at",
               on: .create,
               format: .iso8601)
    var voidedAt: Date?
    
    @Field(key: "logs")
    var logs: [ActionLog]
    
    init() { }
    
    init(id: UUID? = nil,
         month: Int,
         year: Int,
         number: Int = 1,
         status: PurchaseOrderStatus = .pending,
         reference: String? = nil,
         vatOption: VatOption,
         includedVat: Bool,
         vatRate: VatRate,
         items: [PurchaseOrderItem],
         additionalDiscountAmount: Double = 0,
         orderDate: Date = .init(),
         deliveryDate: Date = .init(),
         paymentTermsDays: Int = 30,
         supplierId: UUID,
         customerId: UUID,
         currency: String = "THB",
         note: String = "",
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         pendedAt: Date? = nil,
         deletedAt: Date? = nil,
         approvedAt: Date? = nil,
         voidedAt: Date? = nil,
         logs: [ActionLog] = []) {
        self.id = id
        self.month = month
        self.year = year
        self.number = number
        self.reference = reference
        self.items = items
        self.orderDate = orderDate
        self.deliveryDate = deliveryDate
        self.paymentTermsDays = paymentTermsDays
        self.supplierId = supplierId
        self.customerId = customerId
        self.status = status
        self.currency = currency
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pendedAt = pendedAt
        self.deletedAt = deletedAt
        self.approvedAt = approvedAt
        self.voidedAt = voidedAt
        self.logs = logs
        self.vatOption = vatOption
        self.includedVat = includedVat
        self.vatRate = vatRate.value
        self.additionalDiscountAmount = additionalDiscountAmount
        
        let billItems: [BillItem] = items.map({ .init(description: $0.description,
                                                      quantity: $0.qty,
                                                      pricePerUnit: $0.pricePerUnit,
                                                      discountPerUnit: $0.discountPricePerUnit,
                                                      vatRate: $0.vatRate,
                                                      withholdingTaxRate: $0.taxWithholdingRate,
                                                      vatIncluded: $0.vatIncluded) })
        let summary = BillSummary(items: billItems,
                                  additionalDiscountAmount: additionalDiscountAmount,
                                  vatRate: self.vatRate,
                                  vatIncluded: includedVat)
        
        
        self.totalAmountBeforeDiscount = summary.totalAmountBeforeDiscount
        self.totalAmountBeforeVat = summary.totalAmountBeforeVat
        self.totalAmountAfterVat = summary.totalAmountAfterVat
        self.totalAmountDue = summary.totalAmountDue
        self.totalVatAmount = summary.totalVatAmount
        self.totalWithholdingTaxAmount = summary.totalWithholdingTaxAmount
    }
    
    func ableUpdateStatus() -> [PurchaseOrderStatus] {
        switch status {
        case .draft:
            return [.pending, .voided]
        case .pending:
            return [.approved, .voided]
        case .approved:
            return [.voided]
        default:
            return []
        }
    }
    
    /*
     / statuc flow : draft -> pending
     // statuc flow : draft -> voided
     // status flow : pending -> approved -> voided
     // status flow : pending -> voided
     */
    func moveStatus(newStatus: PurchaseOrderStatus) {
        switch status {
        case .draft:
            switch newStatus {
            case .pending:
                self.status = newStatus
                self.pendedAt = .init()
            case .voided:
                self.status = newStatus
                self.voidedAt = .init()
            default:
                break
            }
        case .pending:
            switch newStatus {
            case .approved:
                self.status = newStatus
                self.approvedAt = .init()
            case .voided:
                self.status = newStatus
                self.voidedAt = .init()
            default:
                break
            }
            
        case .approved:
            switch newStatus {
            case .voided:
                self.status = newStatus
                self.voidedAt = .init()
            default:
                break
            }
        default:
            break
        }
    }
    
}

extension PurchaseOrder {
    
    enum VatOption: String,Codable {
        case vatIncluded = "VAT_INCLUDED"
        case vatExcluded = "VAT_EXCLUDED"
        case noVat = "NO_VAT"
    }
    
}

extension PurchaseOrder {
    
    struct Stub {
        static var po1: PurchaseOrder {
            .init(month: 1,
                  year: 2021,
                  number: 1,
                  status: .pending,
                  reference: "PO-2021-01-01",
                  vatOption: .vatIncluded,
                  includedVat: true,
                  vatRate: ._7,
                  items: [.init(id: nil,
                                itemId: .init(),
                                kind: .product,
                                name: "Product 1",
                                description: "Product 1",
                                variant: nil,
                                qty: 10,
                                pricePerUnit: 10,
                                discountPricePerUnit: 1,
                                additionalDiscount: 0,
                                vatRate: ._7,
                                vatIncluded: true,
                                taxWithholdingRate: ._3)],
                  additionalDiscountAmount: 0,
                  orderDate: .init(),
                  deliveryDate: .init(),
                  paymentTermsDays: 30,
                  supplierId: .init(),
                  customerId: .init())
        }
    }
}
