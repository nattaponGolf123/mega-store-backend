import Foundation
import Vapor
import Fluent

// status flow : pending -> approved -> cancelled
// status flow : pending -> rejected
// status flow : pending -> cancelled
enum PurchaseOrderStatus: String, Codable {
    case pending
    case approved
    case rejected
    case cancelled
}

final class PurchaseOrder: Model, Content {
    static let schema = "PurchaseOrders"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "running_number")
    var runningNumber: String
    
    @Field(key: "revision_number")
    var revisionNumber: Int
    
    @Field(key: "is_lasted_version")
    var isLastedVersion: Bool
    
    @Field(key: "product_items")
    var productItems: [ProductItem]
    
    @Field(key: "service_items")
    var serviceItems: [ServiceItem]
    
    @Field(key: "order_date")
    var orderDate: Date
    
    @Field(key: "delivery_date")
    var deliveryDate: Date
    
    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int
    
    @Field(key: "supplier_id")
    var supplierId: UUID
    
    @Field(key: "supplier_contact_information")
    var supplierContactInformation: ContactInformation
    
    @Field(key: "supplier_business_address")
    var supplierBusinessAddress: BusinessAddress
    
    @Field(key: "customer_id")
    var customerId: UUID

    @Field(key: "customer_contact_information")
    var customerContactInformation: ContactInformation

    @Field(key: "customer_business_address")
    var customerBusinessAddress: BusinessAddress
    
    @Field(key: "status")
    var status: PurchaseOrderStatus
    
    @Field(key: "total_amount")
    var totalAmount: Double
    
    @Field(key: "vat")
    var vat: VatAmount?
    
    @Field(key: "tax_withholding")
    var taxWithholding: TaxWithholding?
    
    @Field(key: "currency")
    var currency: String
    
    @Field(key: "note")
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
    
    @Timestamp(key: "approved_at",
               on: .create,
               format: .iso8601)
    var approvedAt: Date?
    
    @Timestamp(key: "cancelled_at",
               on: .create,
               format: .iso8601)
    var cancelledAt: Date?
    
    @Timestamp(key: "rejected_at",
               on: .create,
               format: .iso8601)
    var rejectedAt: Date?
    
    @Field(key: "creator_id")
    var creatorId: UUID
    
    @Field(key: "document_version")
    var documentVersion: String
    
    @Field(key: "previous_versions")
    var previousVersions: [PurchaseOrder]
    
    init() { }
    
    init(id: UUID? = nil,
         lastedNumber: Int = 1,
         revisionNumber: Int = 0,
         isLastedVersion: Bool = true,
         productItems: [ProductItem],
         serviceItems: [ServiceItem],
         orderDate: Date = .init(),
         deliveryDate: Date = .init(),
         paymentTermsDays: Int = 30,
         supplierId: UUID,
         supplierContactInformation: ContactInformation,
         supplierBusinessAddress: BusinessAddress,
         customerId: UUID,
         customerContactInformation: ContactInformation,
         customerBusinessAddress: BusinessAddress,
         status: PurchaseOrderStatus = .pending,
         currency: String,
         productAndServiceAreVatExcluded: Bool,
         vatIncluded: Bool = false,
         taxWithholdingIncluded: Bool = false,
         note: String = "",
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         deletedAt: Date? = nil,
         creatorId: UUID,
         documentVersion: String = "1.0",
         previousVersions: [PurchaseOrder] = []) {
        
        @RunningNumber(prefix: "PO", 
                       year: Date(),
                       initialValue: lastedNumber)
        var _runningNumber: String
        
        self.id = id ?? .init()
        self.runningNumber = _runningNumber
        self.revisionNumber = revisionNumber
        self.isLastedVersion = isLastedVersion
        self.productItems = productItems
        self.serviceItems = serviceItems
        self.orderDate = orderDate
        self.deliveryDate = deliveryDate
        self.paymentTermsDays = paymentTermsDays
        self.supplierId = supplierId        
        self.supplierContactInformation = supplierContactInformation
        self.supplierBusinessAddress = supplierBusinessAddress
        self.customerId = customerId
        self.customerContactInformation = customerContactInformation
        self.customerBusinessAddress = customerBusinessAddress

        self.status = status
        
        //sum of productItems and serviceItems
        self.totalAmount = Self.sum(productItems: productItems,
                                    serviceItems: serviceItems)
        
        self.vat = Self.vatAmount(productAndServiceAreVatExcluded: productAndServiceAreVatExcluded,
                                  vatIncluded: vatIncluded,
                                  totalAmount: totalAmount)
        
        if let totalAmountIncludeVat = self.vat?.amountAfterVat {
            self.taxWithholding = Self.taxWithholdingAmount(taxWithholdingIncluded: taxWithholdingIncluded,
                                                            totalAmountIncludeVat: totalAmountIncludeVat)
        } else {
            self.taxWithholding = Self.taxWithholdingAmount(taxWithholdingIncluded: taxWithholdingIncluded,
                                                            productAndServiceAreVatExcluded: totalAmount)
        }

        self.currency = currency
        
        self.note = note
        self.createdAt = createdAt ?? .init()
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        
        self.creatorId = creatorId
        self.documentVersion = documentVersion
        self.previousVersions = previousVersions
    }
    
  func ableUpdateStatus() -> [PurchaseOrderStatus] {
        switch status {
        case .pending:
            return [.approved, .rejected, .cancelled]
        case .approved:
            return [.cancelled]
        default:
            return []
        }
  }

  func moveStatus(newStatus: PurchaseOrderStatus) {
        switch status {
        case .pending:
            switch newStatus {
            case .approved:
                self.status = newStatus
                self.approvedAt = .init()
            case .rejected:
                self.status = newStatus
                self.rejectedAt = .init()
            case .cancelled:
                self.status = newStatus
                self.cancelledAt = .init()
            default:
                break
            }

        case .approved:
            switch newStatus {
            case .cancelled:
                self.status = newStatus
                self.cancelledAt = .init()
            default:
                break
            }
        default:
            break
        }
    }

    func prepareUpdate() {
      guard isLastedVersion else { return }

      self.isLastedVersion = false
      previousVersions.append(self)

      self.revisionNumber += 1
            
    }
    
}


extension PurchaseOrder {
    
    static func sum(productItems: [ProductItem], serviceItems: [ServiceItem]) -> Double {
        let productTotal = productItems.reduce(0) { $0 + $1.totalPrice }
        let serviceTotal = serviceItems.reduce(0) { $0 + $1.totalPrice }
        return productTotal + serviceTotal
    }
    
    static func vatAmount(productAndServiceAreVatExcluded: Bool,
                          vatIncluded: Bool,
                          totalAmount: Double) -> VatAmount? {
        if vatIncluded {
            if productAndServiceAreVatExcluded {
                return VatAmount(totalAmountBeforeVat: totalAmount)
            } else {
                return VatAmount(totalAmountIncludeVat: totalAmount)
            }
        }
        
        return  nil
    }
    
    static func taxWithholdingAmount(taxWithholdingIncluded: Bool,
                                     totalAmountIncludeVat: Double) -> TaxWithholding? {
        if taxWithholdingIncluded {
            return TaxWithholding(totalAmount: totalAmountIncludeVat)
        }
        
        return  nil
    }
    
    static func taxWithholdingAmount(taxWithholdingIncluded: Bool,
                                     productAndServiceAreVatExcluded: Double) -> TaxWithholding? {
        if taxWithholdingIncluded {
            return TaxWithholding(totalAmount: productAndServiceAreVatExcluded)
        }
        
        return  nil
    }
    
}


/*
 struct VatAmount: Content {
 
 let amount: Double // vat amount
 let rate: Double // vat rate
 let amountBeforeVat: Double // total amount before vat
 let amountAfterVat: Double // total amount include vat
 
 // include vat
 init(totalAmountIncludeVat: Double,
 rate: Double = 0.07) {
 self.amount = totalAmountIncludeVat
 self.rate = rate
 self.amountBeforeVat = totalAmountIncludeVat / (1 + rate)
 self.amountAfterVat = totalAmountIncludeVat
 }
 
 // exclude vat
 init(totalAmountBeforeVat: Double,
 rate: Double = 0.07) {
 self.amount = totalAmountBeforeVat * rate
 self.rate = rate
 self.amountBeforeVat = totalAmountBeforeVat
 self.amountAfterVat = totalAmountBeforeVat * (1 + rate)
 }
 
 //decode
 init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 self.amount = try container.decode(Double.self,
 forKey: .amount)
 self.rate = try container.decode(Double.self,
 forKey: .rate)
 self.amountBeforeVat = try container.decode(Double.self,
 forKey: .amountBeforeVat)
 self.amountAfterVat = try container.decode(Double.self,
 forKey: .amountAfterVat)
 }
 
 //encode
 func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode(amount, forKey: .amount)
 try container.encode(rate, forKey: .rate)
 try container.encode(amountBeforeVat, forKey: .amountBeforeVat)
 try container.encode(amountAfterVat, forKey: .amountAfterVat)
 }
 
 enum CodingKeys: String, CodingKey {
 case amount
 case rate
 case amountBeforeVat = "amount_before_vat"
 case amountAfterVat = "amount_after_vat"
 }
 
 }
 
 
 struct TaxWithholding: Content {
 
 let amount: Double // tax withholding amount
 let rate: Double // tax withholding rate
 let amountAfterTaxWithholding: Double // total amount after tax withholding
 
 //totalAmount can be 'total amount after vat' or 'total amount without vat'
 init(totalAmount: Double,
 rate: Double = 0.03) {
 self.amount = totalAmount * rate
 self.rate = rate
 self.amountAfterTaxWithholding = totalAmount - (totalAmount * rate)
 }
 
 //decode
 init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 self.amount = try container.decode(Double.self,
 forKey: .amount)
 self.rate = try container.decode(Double.self,
 forKey: .rate)
 self.amountAfterTaxWithholding = try container.decode(Double.self,
 forKey: .amountAfterTaxWithholding)
 }
 
 //encode
 func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode(amount, forKey: .amount)
 try container.encode(rate, forKey: .rate)
 try container.encode(amountAfterTaxWithholding, forKey: .amountAfterTaxWithholding)
 }
 
 enum CodingKeys: String, CodingKey {
 case amount
 case rate
 case amountAfterTaxWithholding = "amount_after_tax_withholding"
 }
 }
 
 @propertyWrapper
 struct RunningNumber {
 let prefix: String
 let year: Int
 let currentValue: Int
 
 var wrappedValue: String {
 get {
 let formattedYear = String(format: "%04d", year)
 let formattedNumber = String(format: "%05d", currentValue)
 return "\(prefix)-\(formattedYear)-\(formattedNumber)"
 }
 mutating set {
 // You can handle setting the value if needed
 // For simplicity, we don't support setting the value explicitly in this example
 // You may need to implement this based on your use case
 }
 }
 
 init(prefix: String,
 year: Date = .init(),
 initialValue: Int = 1) {
 self.prefix = prefix
 self.year = Calendar.current.component(.year,
 from: year)
 self.currentValue = initialValue
 }
 }
 
 Purchase Order :json draft of response
 {
 "id" : "SADASDASD!@#!@#!@#"", // as UUID
 "running_number": "PO-2024-00001", // running number with format PO-2024-00001
 "revision_number": 1, // revision number or null
 "is_lasted_version" : true, // is lastest version or null
 "product_items": [
 {
 "id" : "QWQEQWCSAASD", // product_item UUID
 "product_id": "QWQEQWCSAASD", // product UUID
 "name": "Widget A",
 "description": "Widget A - Pack of 10",
 "variant": {
 "variant_id": "QWQEQWCSAASD", // variant UUID
 "variant_sku": "WID-A-10",
 "variant_name": "Pack of 10",
 "additional_description": "Pack of 10",
 "color": "Red",
 }
 "quantity": 100.0,
 "selling_price": 5.99,
 "total_price": 599.00,
 "unit": "pack",
 "remark": "This is a remark"
 } , {
 "id" : "QWQEQWCSAASD", // product_item UUID
 "product_id": "QWQEQWCSAASD", // product UUID
 "name": "Widget B",
 "description": "Widget B - Pack of 5",
 "variant": null,
 "quantity": 100.0,
 "selling_price": 5.99,
 "total_price": 599.00,
 "unit": "pack",
 "remark": "This is a remark"
 }
 ],
 "service_items": [
 {
 "id" : "QWQEQWCSAASD", // service_item UUID
 "name": "Service A",
 "description": "Service A - Pack of 10",
 "quantity": 100.0,
 "price": 5.99,
 "total_price": 599.00,
 "unit": "pack",
 "remark": "This is a remark"
 }
 ],
 "order_date": "2024-05-03",
 "delivery_date": "2024-05-10",
 "payment_terms_days": 30,
 "supplier_id": "SUP12345", // supplier UUID
 "supplier_vat_registered": true,
 "supplier_contact_information" : { // copy value from supplier contact information
 "contact_person": "John Doe",
 "phone_number": "1234567890",
 "email": "",
 "address": "1234 Main St"
 },
 "supplier_business_address" : { // copy value from supplier business address
 "address": "123",
 "city": "Bangkok",
 "postal_code": "12022",
 "country": "Thailand",
 "phone_number": "123-456-7890",
 "email": "",
 "fax": ""
 },
 "status": "pending",
 "vat" : {
 "amount": 98.50, // vat amount or null
 "rate": 0.07,
 "amount_before_vat": 1098.50, // total amount before vat or null
 },
 "tax_withholding" : {
 "amount" : 32.95, // tax withholding amount or null
 "rate" : 0.03,
 "amount_after_tax_withholding" : 1065.55, // total amount after tax withholding or null
 },
 "currency": "THB",
 "total_amount_before_vat": 1098.50, // total amount before vat or null
 "total_amount": 1098.50, // total amount include vat
 "tax_withholding": 0.03, // tax withholding rate
 "tax_withholding_amount": 32.95, // tax withholding amount or null
 "total_amount_after_tax_withholding": 1065.55, // total amount after tax withholding or null
 "note": "This is a note",
 "created_at": "2024-05-03T07:00:00Z",
 "updated_at": "2024-05-03T07:00:00Z",
 "deleted_at": "2024-05-03T07:00:00Z",
 "creator_id": "USR12345", // user UUID
 "document_version" : "1.0",
 "previous_versions" : [] // previous purchase order object
 }
 */

/*
 final class Service: Model, Content {
 static let schema = "Services"
 
 @ID(key: .id)
 var id: UUID?
 
 @Field(key: "name")
 var name: String
 
 @Field(key: "description")
 var description: String
 
 @Field(key: "price")
 var price: Double
 
 @Field(key: "unit")
 var unit: String
 
 @Field(key: "category_id")
 var categoryId: UUID?
 
 @Field(key: "images")
 var images: [String]
 
 @Field(key: "cover_image")
 var coverImage: String?
 
 @Field(key: "tags")
 var tags: [String]
 
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
 
 init() { }
 
 init(id: UUID? = nil,
 name: String,
 description: String,
 price: Double,
 unit: String,
 categoryId: UUID? = nil,
 images: [String] = [],
 coverImage: String? = nil,
 tags: [String] = [],
 createdAt: Date? = nil,
 updatedAt: Date? = nil,
 deletedAt: Date? = nil) {
 self.id = id ?? .init()
 self.name = name
 self.description = description
 self.price = price
 self.unit = unit
 self.categoryId = categoryId
 self.images = images
 self.createdAt = createdAt ?? Date()
 self.updatedAt = updatedAt
 self.deletedAt = deletedAt
 }
 
 }
 final class ProductVariant:Model, Content {
 static let schema = "ProductVariant"
 
 @ID(key: .id)
 var id: UUID?
 
 @Field(key: "variant_id")
 var variantId: String
 
 @Field(key: "variant_name")
 var name: String
 
 @Field(key: "variant_sku")
 var sku: String
 
 @Field(key: "price")
 var sellingPrice: Double
 
 @Field(key: "additional_description")
 var additionalDescription: String
 
 @Field(key: "image")
 var image: String?
 
 @Field(key: "color")
 var color: String?
 
 @Field(key: "barcode")
 var barcode: String?
 
 @Field(key: "dimensions")
 var dimensions: ProductDimension?
 
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
 
 init() { }
 
 init(id: UUID? = nil,
 variantId: String? = nil,
 name: String,
 sku: String,
 sellingPrice: Double,
 additionalDescription: String,
 image: String? = nil,
 color: String? = nil,
 barcode: String? = nil,
 dimensions: ProductDimension? = nil,
 createdAt: Date? = nil,
 updatedAt: Date? = nil,
 deletedAt: Date? = nil) {
 
 @UniqueVariantId
 var _variantId: String
 
 self.id = id ?? .init()
 self.variantId = variantId ?? _variantId
 self.name = name
 self.sku = sku
 self.sellingPrice = sellingPrice
 self.additionalDescription = additionalDescription
 self.image = image
 self.color = color
 self.barcode = barcode
 self.dimensions = dimensions
 self.createdAt = createdAt
 self.updatedAt = updatedAt
 self.deletedAt = deletedAt
 }
 
 final class Product: Model, Content {
 static let schema = "Products"
 
 @ID(key: .id)
 var id: UUID?
 
 @Field(key: "name")
 var name: String
 
 @Field(key: "description")
 var description: String
 
 @Field(key: "unit")
 var unit: String
 
 @Field(key: "selling_price")
 var sellingPrice: Double
 
 @Field(key: "category_id")
 var categoryId: UUID?
 
 @Field(key: "manufacturer")
 var manufacturer: String
 
 @Field(key: "barcode")
 var barcode: String?
 
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
 
 @Field(key: "images")
 var images: [String]
 
 @Field(key: "cover_image")
 var coverImage: String?
 
 @Field(key: "tags")
 var tags: [String]
 
 @Field(key: "suppliers")
 var suppliers: [UUID]
 
 @Field(key: "variants")
 var variants: [ProductVariant]
 
 init() { }
 
 init(id: UUID? = nil,
 name: String,
 description: String,
 unit: String,
 sellingPrice: Double = 0,
 categoryId: UUID? = nil,
 manufacturer: String = "",
 barcode: String? = nil,
 images: [String] = [],
 coverImage: String? = nil,
 tags: [String] = [],
 suppliers: [UUID] = [],
 variants: [ProductVariant] = [],
 createdAt: Date? = nil,
 updatedAt: Date? = nil,
 deletedAt: Date? = nil) {
 self.id = id
 self.name = name
 self.description = description
 self.unit = unit
 self.sellingPrice = sellingPrice
 self.categoryId = categoryId
 self.manufacturer = manufacturer
 self.barcode = barcode
 self.createdAt = createdAt
 self.updatedAt = updatedAt
 self.deletedAt = deletedAt
 self.images = images
 self.coverImage = coverImage
 self.tags = tags
 self.suppliers = suppliers
 self.variants = variants
 }
 
 }
 */
