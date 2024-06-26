import Foundation
import Vapor
import Fluent

extension PurchaseOrderRepository {
    
    enum SortBy: String, Codable {        
        case number
        case status
        case orderDate = "order_date"
        case createdAt = "created_at"
        case supplierId = "supplier_id"
        case totalAmount = "total_amount"
    }
    
    enum SortOrder: String, Codable {
        case asc
        case desc
    }
    
    enum Status: String, Codable {
        case all
        case draft
        case pending
        case approved
        case voided
    }

    enum VatRateOption: String, Codable {
        case none = "NONE"
        case vat7 = "VAT_7"
        case vat0 = "VAT_0"

        var rate: Double {
            switch self {
            case .none:
                return 0
            case .vat7:
                return 0.07
            case .vat0:
                return 0
            }
        }
    }

    enum TaxWithholdingRateOption: String, Codable {
        case none = "NONE"
        case tax0_75 = "TAX_0_75"
        case tax1 = "TAX_1"
        case tax1_5 = "TAX_1_5"
        case tax2 = "TAX_2"
        case tax3 = "TAX_3"
        case tax5 = "TAX_5"
        case tax10 = "TAX_10"
        case tax15 = "TAX_15"

        var rate: Double {
            switch self {
            case .none:
                return 0
            case .tax0_75:
                return 0.0075
            case .tax1:
                return 0.01
            case .tax1_5:
                return 0.015
            case .tax2:
                return 0.02
            case .tax3:
                return 0.03
            case .tax5:
                return 0.05
            case .tax10:
                return 0.1
            case .tax15:
                return 0.15
            }
        }
    }

    struct Fetch: Content, Validatable {
        let status: Status
        let page: Int
        let perPage: Int
        let sortBy: SortBy
        let sortOrder: SortOrder
        let periodDate: PeriodDate
        
        init(status: Status = .all,
             page: Int = 1,
             perPage: Int = 20,
             sortBy: SortBy = .number,
             sortOrder: SortOrder = .asc,
             periodDate: PeriodDate) {
            self.status = status
            self.page = page
            self.perPage = perPage
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self.periodDate = periodDate
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.status = (try? container.decode(Status.self, forKey: .status)) ?? .all
            self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
            self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
            self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
            self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
            
            let dateFormat = "yyyy-MM-dd"
            let from = try container.decode(String.self, forKey: .from).tryToDate(dateFormat)
            let to = try container.decode(String.self, forKey: .to).tryToDate(dateFormat)
            self.periodDate = .init(from: from,
                                    to: to)
        }
        
        func purchaseOrderStatus() -> PurchaseOrderStatus? {
            switch status {
            case .all:
                return nil
            case .pending:
                return .pending
            case .approved:
                return .approved
            case .draft:
                return .draft
            case .voided:
                return .voided
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status, forKey: .status)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
            try container.encode(periodDate.fromDateFormat, forKey: .from)
            try container.encode(periodDate.toDateFormat, forKey: .to)
        }
        
        static func validations(_ validations: inout Validations) {
            let dateFormat = "yyyy-MM-dd"
            validations.add("from", as: String.self, is: .date(format: dateFormat), required: false)
            validations.add("to", as: String.self, is: .date(format: dateFormat), required: false)
            validations.add("page", as: Int.self, is: .range(1...), required: false)
            validations.add("per_page", as: Int.self, is: .range(1...100), required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
            case from
            case to
        }
    }
    
    struct Search: Content, Validatable{
        let q: String
        let page: Int
        let perPage: Int
        let status: Status
        let sortBy: SortBy
        let sortOrder: SortOrder
        let periodDate: PeriodDate

        init(q: String,
             page: Int = 1,
             perPage: Int = 20,
             status: Status = .all,
             sortBy: SortBy = .createdAt,
             sortOrder: SortOrder = .asc,
             periodDate: PeriodDate) {
            self.q = q
            self.page = page
            self.perPage = perPage
            self.status = status
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self.periodDate = periodDate
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.q = try container.decode(String.self, forKey: .q)
            self.page = try container.decode(Int.self, forKey: .page)
            self.perPage = try container.decode(Int.self, forKey: .perPage)
            self.status = try container.decode(Status.self, forKey: .status)
            self.sortBy = try container.decode(SortBy.self, forKey: .sortBy)
            self.sortOrder = try container.decode(SortOrder.self, forKey: .sortOrder)
            
            let dateFormat = "yyyy-MM-dd"
            let from = try container.decode(String.self, forKey: .from).tryToDate(dateFormat)
            let to = try container.decode(String.self, forKey: .to).tryToDate(dateFormat)
            self.periodDate = .init(from: from,
                                    to: to)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(q, forKey: .q)
            try container.encode(page, forKey: .page)
            try container.encode(perPage, forKey: .perPage)
            try container.encode(status, forKey: .status)
            try container.encode(sortBy, forKey: .sortBy)
            try container.encode(sortOrder, forKey: .sortOrder)
            try container.encode(periodDate.fromDateFormat, forKey: .from)
            try container.encode(periodDate.toDateFormat, forKey: .to)
        }
        
        static func validations(_ validations: inout Validations) {
            let dateFormat = "yyyy-MM-dd"
            validations.add("from", as: String.self, is: .date(format: dateFormat), required: false)
            validations.add("to", as: String.self, is: .date(format: dateFormat), required: false)
            validations.add("page", as: Int.self, is: .range(1...), required: false)
            validations.add("per_page", as: Int.self, is: .range(1...100), required: false)
        }
        
        enum CodingKeys: String, CodingKey {
            case q
            case page
            case perPage = "per_page"
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
            case status
            case from
            case to
        }
    }

    struct CreatePurchaseOrderItem: Content, Validatable {
        let itemId: UUID
        let kind: PurchaseOrderItem.Kind
        let name: String
        let description: String
        let variantId: UUID?
        let qty: Double
        let pricePerUnit: Double
        let discountPricePerUnit: Double
        let vatRateOption: VatRateOption
        let vatIncluded: Bool
        let withholdingTaxRateOption: TaxWithholdingRateOption      

        init(itemId: UUID,
             kind: PurchaseOrderItem.Kind,
             name: String,
             description: String,
             variantId: UUID?,
             qty: Double,
             pricePerUnit: Double,
             discountPricePerUnit: Double,
             vatRateOption: VatRateOption,
             vatIncluded: Bool,
             withholdingTaxRateOption: TaxWithholdingRateOption) {
            self.itemId = itemId
            self.kind = kind
            self.name = name
            self.description = description
            self.variantId = variantId
            self.qty = qty
            self.pricePerUnit = pricePerUnit
            self.discountPricePerUnit = discountPricePerUnit
            self.vatRateOption = vatRateOption
            self.vatIncluded = vatIncluded
            self.withholdingTaxRateOption = withholdingTaxRateOption
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.itemId = try container.decode(UUID.self, forKey: .itemId)
            self.kind = try container.decode(PurchaseOrderItem.Kind.self, forKey: .kind)
            self.name = try container.decode(String.self, forKey: .name)
            self.description = try container.decode(String.self, forKey: .description)
            self.variantId = try? container.decode(UUID.self, forKey: .variantId)
            self.qty = try container.decode(Double.self, forKey: .qty)
            self.pricePerUnit = try container.decode(Double.self, forKey: .pricePerUnit)
            self.discountPricePerUnit = (try? container.decode(Double.self, forKey: .discountPricePerUnit)) ?? 0
            self.vatRateOption = try container.decode(VatRateOption.self, forKey: .vatRateOption)
            self.vatIncluded = try container.decode(Bool.self, forKey: .vatIncluded)
            self.withholdingTaxRateOption = try container.decode(TaxWithholdingRateOption.self, forKey: .withholdingTaxRateOption)
        }

        static func validations(_ validations: inout Validations) {
            validations.add("qty", as: Double.self, is: .range(0...))
            validations.add("price_per_unit", as: Double.self, is: .range(0...))
            validations.add("discount_price_per_unit", as: Double.self, is: .range(0...))            
            validations.add("vat_rate_option", as: VatRateOption.self, required: true)
            validations.add("vat_included", as: Bool.self, required: true)
            validations.add("withholding_tax_rate_option", as: TaxWithholdingRateOption.self, required: true)            
        }  

        enum CodingKeys: String, CodingKey {
            case itemId = "item_id"
            case kind
            case name
            case description
            case variantId = "variant_id"
            case qty
            case pricePerUnit = "price_per_unit"
            case discountPricePerUnit = "discount_price_per_unit"
            case vatRateOption = "vat_rate_option"
            case vatIncluded = "vat_included"
            case withholdingTaxRateOption = "withholding_tax_rate_option"
        }
    }
    
    struct Create: Content, Validatable {
        let reference: String
        let note: String
        let paymentTermsDays: Int
        let supplierId: UUID        
        let deliveryDate: Date
        let customerId: UUID
        let items: [CreatePurchaseOrderItem]
        let vatOption: PurchaseOrder.VatOption
        let orderDate: Date
        let additionalDiscountAmount: Double
        let currency: CurrencySupported
        let includedVat: Bool
        let vatRateOption: VatRateOption

       
        init(reference: String,
             note: String,                          
             supplierId: UUID,
             customerId: UUID,
             orderDate: Date,
             deliveryDate: Date,
             paymentTermsDays: Int,
             items: [CreatePurchaseOrderItem],
             additionalDiscountAmount: Double,
             vatOption: PurchaseOrder.VatOption,
             includedVat: Bool,
             vatRateOption: VatRateOption,
             currency: CurrencySupported) {
            self.reference = reference
            self.note = note
            
            self.paymentTermsDays = paymentTermsDays
            self.deliveryDate = deliveryDate
            self.orderDate = orderDate

            self.supplierId = supplierId
            self.customerId = customerId            
            
            self.items = items
            self.additionalDiscountAmount = additionalDiscountAmount

            self.currency = currency
            self.vatOption = vatOption
            self.includedVat = includedVat
            self.vatRateOption = vatRateOption            
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.reference = try container.decode(String.self, forKey: .reference)
            self.note = try container.decode(String.self, forKey: .note)            
            self.paymentTermsDays = try container.decode(Int.self, forKey: .paymentTermsDays)
            
            self.supplierId = try container.decode(UUID.self, forKey: .supplierId)
            self.customerId = try container.decode(UUID.self, forKey: .customerId)
            
            self.items = try container.decode([CreatePurchaseOrderItem].self, forKey: .items)
            self.additionalDiscountAmount = (try? container.decode(Double.self, forKey: .additionalDiscountAmount)) ?? 0
            
            let dateFormat = "yyyy-MM-dd"
            self.orderDate = try container.decode(String.self, forKey: .orderDate).tryToDate(dateFormat)
            self.deliveryDate = try container.decode(String.self, forKey: .deliveryDate).tryToDate(dateFormat)
                        
            self.currency = (try? container.decode(CurrencySupported.self, forKey: .currency)) ?? .thb
            self.vatOption = try container.decode(PurchaseOrder.VatOption.self, forKey: .vatOption)
            self.includedVat = (try? container.decode(Bool.self, forKey: .includedVat)) ?? false
            self.vatRateOption = (try? container.decode(VatRateOption.self, forKey: .vatRateOption)) ?? .none

        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(reference, forKey: .reference)
            try container.encode(note, forKey: .note)
            try container.encode(paymentTermsDays, forKey: .paymentTermsDays)
            try container.encode(supplierId, forKey: .supplierId)
            try container.encode(customerId, forKey: .customerId)
            try container.encode(items, forKey: .items)
            try container.encode(additionalDiscountAmount, forKey: .additionalDiscountAmount)
            try container.encode(currency, forKey: .currency)
            try container.encode(vatOption, forKey: .vatOption)
            try container.encode(includedVat, forKey: .includedVat)
            try container.encode(vatRateOption, forKey: .vatRateOption)
            
            let dateFormat = "yyyy-MM-dd"
            try container.encode(orderDate.toDateString(dateFormat), forKey: .orderDate)
            try container.encode(deliveryDate.toDateString(dateFormat), forKey: .deliveryDate)            
        }
        
        func yearNumber() -> Int {
            Calendar.current.component(.year,
                                       from: orderDate)
        }

        func monthNumber() -> Int {
            Calendar.current.component(.month,
                                       from: orderDate)
        }


        static func validations(_ validations: inout Validations) {
            validations.add("reference", as: String.self, is: .count(1...200))
            validations.add("note", as: String.self, is: .count(0...200))            
            validations.add("payment_terms_days", as: Int.self, is: .range(0...))
            validations.add("supplier_id", as: UUID.self, required: true)            
            validations.add("delivery_date", as: Date.self, required: true)
            validations.add("customer_id", as: UUID.self, required: true)
            validations.add("items", as: [CreatePurchaseOrderItem].self, is: !.empty)
            validations.add("vat_option", as: PurchaseOrder.VatOption.self, required: true)
            validations.add("order_date", as: Date.self, required: true)
            validations.add("additional_discount_amount", as: Double.self, is: .range(0...))
            validations.add("currency", as: CurrencySupported.self, required: true)     
            validations.add("included_vat", as: Bool.self, required: true)
            validations.add("vat_rate_option", as: VatRateOption.self, required: true)             
        }

        enum CodingKeys: String, CodingKey {
            case reference
            case note
            case paymentTermsDays = "payment_terms_days"
            case supplierId = "supplier_id"
            case totalAmountBeforeVat = "total_amount_before_vat"
            case deliveryDate = "delivery_date"
            case customerId = "customer_id"
            case items
            case vatOption = "vat_option"
            case orderDate = "order_date"
            case additionalDiscountAmount = "additional_discount_amount"
            case currency
            case includedVat = "included_vat"
            case vatRateOption = "vat_rate_option"
        }

        
    }
    
    struct Update: Content, Validatable {
        let name: String?
        let description: String?
        let price: Double?
        let unit: String?
        let categoryId: UUID?
        let images: [String]?
        let coverImage: String?
        let tags: [String]?
        
        init(name: String? = nil,
             description: String? = nil,
             price: Double? = nil,
             unit: String? = nil,
             categoryId: UUID? = nil,
             images: [String]? = nil,
             coverImage: String? = nil,
             tags: [String]? = nil) {
            self.name = name
            self.description = description
            self.price = price
            self.unit = unit
            self.categoryId = categoryId
            self.images = images
            self.coverImage = coverImage
            self.tags = tags
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(String.self, forKey: .name)
            self.description = try? container.decode(String.self, forKey: .description)
            self.price = try? container.decode(Double.self, forKey: .price)
            self.unit = try? container.decode(String.self, forKey: .unit)
            self.categoryId = try? container.decode(UUID.self, forKey: .categoryId)
            self.images = try? container.decode([String].self, forKey: .images)
            self.coverImage = try? container.decode(String.self, forKey: .coverImage)
            self.tags = try? container.decode([String].self, forKey: .tags)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case price
            case unit
            case categoryId = "category_id"
            case images
            case coverImage = "cover_image"
            case tags
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...200))
            validations.add("price", as: Double.self, is: .range(0...))
        }
    }
    
    struct ReplaceItems: Content, Validatable {
        let items: [PurchaseOrderItem]
        
        init(items: [PurchaseOrderItem]) {
            self.items = items
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.items = try container.decode([PurchaseOrderItem].self,
                                              forKey: .items)
        }
        
        enum CodingKeys: String, CodingKey {
            case items
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("items", as: [PurchaseOrderItem].self, is: !.empty)
        }
                
    }
    
    struct ReorderItems: Content, Validatable {
        let itemIdOrder: [UUID]
        
        init(itemIdOrder: [UUID]) {
            self.itemIdOrder = itemIdOrder
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.itemIdOrder = try container.decode([UUID].self,
                                              forKey: .itemIdOrder)
        }
        
        enum CodingKeys: String, CodingKey {
            case itemIdOrder = "item_id_order"
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("item_id_order", as: [UUID].self, is: !.empty)
        }
        
    }
    
//    struct AddContact: Content {
//        let contactId: UUID
//        
//        enum CodingKeys: String, CodingKey {
//            case contactId = "contact_id"
//        }
//        
//    }
    
}

/*
Create JSON body
{
    "reference": "PO-2021-01-01",
    "note": "",    
    "payment_terms_days": 30,
    "supplier_id": "A9B5EA51-8A9B-4B69-93CD-0D2DBC542BE4",    
    "delivery_date": "2024-06-25T07:41:21Z",
    "customer_id": "2E5CEE1F-2098-471F-9967-D5E4213DF560",
    "items": [
        {
            "item_id": "403754C2-C130-43A3-975B-0D9DB96716B7",
            "kind": "PRODUCT",
            "name": "Product 1",
            "description": "Product 1",
            "variant_id": null,
            "qty": 10.0,
            "price_per_unit": 10.0,
            "discount_price_per_unit": 1.0,
            "vat_rate": 0.07,
            "vat_included": true,
            "withholding_tax_rate": 0.03
        }
    ],
    "vat_option": "VAT_INCLUDED",
    "order_date": "2024-06-25T07:41:21Z",
    "additional_discount_amount": 0,
    "currency": "THB",
    "included_vat": true,
    "vat_rate": 0.07
}
*/
