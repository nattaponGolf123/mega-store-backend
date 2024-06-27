import Foundation
import Vapor
import Fluent

protocol PurchaseOrderRepositoryProtocol {
    func all(content: PurchaseOrderRepository.Fetch,
             on db: Database) async throws -> PaginatedResponse<PurchaseOrderResponse>
    func create(content: PurchaseOrderRepository.Create,
                userId: UUID,
                on db: Database) async throws -> PurchaseOrderResponse
    func find(id: UUID,
              on db: Database) async throws -> PurchaseOrderResponse
    func update(id: UUID,
                with content: PurchaseOrderRepository.Update,
                userId: UUID,
                on db: Database) async throws -> PurchaseOrderResponse
    func replaceItems(id: UUID,
                      with content: PurchaseOrderRepository.ReplaceItems,
                      userId: UUID,
                      on db: Database) async throws -> PurchaseOrderResponse
 
    func itemsReorder(id: UUID,
                      userId: UUID,
                      itemsOrder: [UUID],
                      on db: Database) async throws -> PurchaseOrderResponse    
    
    func approve(id: UUID,
                 userId: UUID,
                 on db: Database) async throws -> PurchaseOrderResponse
    func reject(id: UUID,
                userId: UUID,
                on db: Database) async throws -> PurchaseOrderResponse
    func cancel(id: UUID,
                userId: UUID,
                on db: Database) async throws -> PurchaseOrderResponse
    func void(id: UUID,
              userId: UUID,
              on db: Database) async throws -> PurchaseOrderResponse
    
    func search(content: PurchaseOrderRepository.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrderResponse>
    func fetchLastedNumber(year: Int,
                           month: Int,
                           on db: Database) async throws -> Int
}

class PurchaseOrderRepository: PurchaseOrderRepositoryProtocol {
   
    typealias CreateContent = PurchaseOrderRepository.Create
    
    private var productRepository: ProductRepositoryProtocol
    private var serviceRepository: ServiceRepositoryProtocol
    private var myBusineseRepository: MyBusineseRepositoryProtocol
    private var contactRepository: ContactRepositoryProtocol
    
    let stub = PurchaseOrder(month: 1,
                             year: 2024,
                             vatOption: .noVat,
                             includedVat: false,
                             items: [],
                             supplierId: .init(),
                             customerId: .init())
    
    init(productRepository: ProductRepositoryProtocol = ProductRepository(),
         serviceRepository: ServiceRepositoryProtocol = ServiceRepository(),
         myBusineseRepository: MyBusineseRepositoryProtocol = MyBusineseRepository(),
         contactRepository: ContactRepositoryProtocol = ContactRepository()) {
        self.productRepository = productRepository
        self.serviceRepository = serviceRepository
        self.myBusineseRepository = myBusineseRepository
        self.contactRepository = contactRepository
    }
    
    func all(content: PurchaseOrderRepository.Fetch,
             on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrderResponse> {
        do {
            let page = content.page
            let perPage = content.perPage
            let from = content.periodDate.from
            let to = content.periodDate.to
            
            guard
                page > 0,
                perPage > 0
            else { throw DefaultError.invalidInput }
            
            let query = queryBuilder(from: from,
                                     to: to,
                                     status: content.purchaseOrderStatus(),
                                     on: db)
            
            let total = try await query.count()
            
            //query sorted by name
            let items = try await sortQuery(query: query,
                                            sortBy: content.sortBy,
                                            sortOrder: content.sortOrder,
                                            status: content.status,
                                            periodDate: content.periodDate,
                                            page: page,
                                            perPage: perPage)
            let itemResponses: [PurchaseOrderResponse] = items.map { PurchaseOrderResponse(po: $0) }
            
            let response = PaginatedResponse(page: page,
                                             perPage: perPage,
                                             total: total,
                                             items: itemResponses)
            
            return response
        } catch {
            // Handle all other errors
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func create(content: PurchaseOrderRepository.Create,
                userId: UUID,
                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        do {
            // validate exist supplierId , customerId
            guard
                let _ = try? await contactRepository.find(id: content.supplierId,
                                                          on: db),
                let customerId = try? await myBusineseRepository.fetchAll(on: db).first?.id
            else {
                throw DefaultError.error(message: "supplier or customer not found")
            }
            
            
            // validate exist productId
            do {
                for uuid in content.productUUIDs() {
                    let _ = try await productRepository.find(id: uuid, on: db)
                }
            } catch {
                throw DefaultError.error(message: "product not found")
            }
            
            // validate exist serviceId
            do {
                for uuid in content.serviceUUIDs() {
                    let _ = try await serviceRepository.find(id: uuid, on: db)
                }
            } catch {
                throw DefaultError.error(message: "service not found")
            }
            
            let yearNumber = content.yearNumber()
            let monthNumber = content.monthNumber()
            let lastedNumber = try await fetchLastedNumber(year: content.yearNumber(),
                                                           month: content.monthNumber(),
                                                           on: db)
            let nextNumber = lastedNumber + 1
            
            let poItems = content.poItems()
            let newModel = PurchaseOrder(month: monthNumber,
                                         year: yearNumber,
                                         number: nextNumber,
                                         reference: content.reference,
                                         vatOption: content.vatOption,
                                         includedVat: content.includedVat,
                                         items: poItems,
                                         additionalDiscountAmount: content.additionalDiscountAmount,
                                         orderDate: content.orderDate,
                                         deliveryDate: content.deliveryDate,
                                         paymentTermsDays: content.paymentTermsDays,
                                         supplierId: content.supplierId,
                                         customerId: customerId,
                                         currency: content.currency,
                                         note: content.note,
                                         userId: userId)
            
            try await newModel.save(on: db)
            
            return PurchaseOrderResponse(po: newModel)
        } catch {
            throw DefaultError.error(message: error.localizedDescription)
        }
    }
    
    func find(id: UUID,
              on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        guard
            let model = try await PurchaseOrder.query(on: db).filter(\.$id == id).first()
        else { throw DefaultError.notFound }
        
        return PurchaseOrderResponse(po: model)
    }
    
    /*
     //PurchaseOrderRepository.Update
     struct Update: Content, Validatable {
         let reference: String?
         let note: String?
         let paymentTermsDays: Int?
         let supplierId: UUID?
         let deliveryDate: Date?
         let items: [UpdateItem]?
         let vatOption: PurchaseOrder.VatOption?
         let orderDate: Date?
         let additionalDiscountAmount: Double?
         let currency: CurrencySupported?
         let includedVat: Bool?
         let vatRateOption: VatRateOption?
         
     */
    func update(id: UUID,
                with content: PurchaseOrderRepository.Update,
                userId: UUID,
                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        guard
            let model = try await PurchaseOrder.query(on: db).filter(\.$id == id).first()
        else { throw DefaultError.notFound }
        
        // validate exist supplierId , customerId
        if let supplierId = content.supplierId {
            guard
                let _ = try? await contactRepository.find(id: supplierId,
                                                          on: db)
            else {
                throw DefaultError.error(message: "supplier not found")
            }
            
            model.supplierId = supplierId
        }
        
        if let reference = content.reference {
            model.reference = reference
        }
        
        if let note = content.note {
            model.note = note
        }
        
        if let paymentTermsDays = content.paymentTermsDays {
            model.paymentTermsDays = paymentTermsDays
        }
        
        if let deliveryDate = content.deliveryDate {
            model.deliveryDate = deliveryDate
        }
        
        if let currency = content.currency {
            model.currency = currency
        }
        
//        if let includedVat = content.includedVat {
//            model.includedVat = includedVat
//        }
//        
//        if let vatRateOption = content.vatRateOption {
//            model.vatRate = vatRateOption.vatRate
//        }
        
//        if let orderDate = content.orderDate {
//            model.orderDate = orderDate
//        }
        
        
        
        if let productUUIDS = content.productUUIDs() {
            // validate exist productId
            do {
                for uuid in productUUIDS {
                    let _ = try await productRepository.find(id: uuid, on: db)
                }
            } catch {
                throw DefaultError.error(message: "product not found")
            }
        }
        
        if let serviceUUIDs = content.serviceUUIDs() {
            // validate exist serviceId
            do {
                for uuid in serviceUUIDs {
                    let _ = try await serviceRepository.find(id: uuid, on: db)
                }
            } catch {
                throw DefaultError.error(message: "service not found")
            }
        }
        
       
        if let items = content.poItems() {
          
            let updateModel = model.replaceItems(items: items)
        }
        
        
        // update and validate
        
        
        return PurchaseOrderResponse(po: model)
    }
    
    func replaceItems(id: UUID,
                      userId: UUID,
                      with content: ReplaceItems, on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func approve(id: UUID,
                 userId: UUID,
                 on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func reject(id: UUID, 
                userId: UUID,
                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func cancel(id: UUID, 
                userId: UUID,
                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func void(id: UUID,
              userId: UUID,
              on db: Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func replaceItems(id: UUID, 
                      with content: ReplaceItems,
                      userId: UUID,
                      on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func itemsReorder(id: UUID,
                      userId: UUID,
                      itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrderResponse {
        return .init(po: stub)
    }
    
    func search(content: PurchaseOrderRepository.Search,
                on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrderResponse> {
        return .init(page: 1,
                     perPage: 20,
                     total: 0,
                     items: [])
    }
    
    func fetchLastedNumber(year: Int,
                           month: Int,
                           on db: Database) async throws -> Int {
        // fetch PurchaseOrder with match "year" , "month"
        let query = PurchaseOrder.query(on: db).filter(\.$year == year).filter(\.$month == month)
        query.sort(\.$number, .descending)
        query.limit(1)
        
        let model = try await query.first()
        
        return model?.number ?? 0
    }
    
}

private extension PurchaseOrderRepository {
    
    //query with 'from' date "yyyy-MM-dd" to date 'yyyy-MM-dd' and filter with status?
    func queryBuilder(from: Date,
                      to: Date,
                      status: PurchaseOrderStatus?,
                      on db: any FluentKit.Database) -> QueryBuilder<PurchaseOrder> {
        var query = PurchaseOrder.query(on: db)
            .filter(\.$orderDate >= from)
            .filter(\.$orderDate <= to)
        
        if let status = status {
            query = query.filter(\.$status == status)
        }
        
        return query
    }
    
    func sortQuery(query: QueryBuilder<PurchaseOrder>,
                   sortBy: PurchaseOrderRepository.SortBy,
                   sortOrder: PurchaseOrderRepository.SortOrder,
                   status: PurchaseOrderRepository.Status,
                   periodDate: PeriodDate,
                   page: Int,
                   perPage: Int) async throws -> [PurchaseOrder] {
        switch sortBy {
        case .status:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$status).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$status, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .createdAt:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .number:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .totalAmount:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$totalAmountDue).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$totalAmountDue, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .supplierId:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$supplierId).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$supplierId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .orderDate:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$orderDate).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$orderDate, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        }
    }
    
    static func updateFieldsBuilder(uuid: UUID, 
                                    content: PurchaseOrderRepository.Update,
                                    db: Database) -> QueryBuilder<PurchaseOrder> {
        let updateBuilder = PurchaseOrder.query(on: db).filter(\.$id == uuid)
        
        if let reference = content.reference {
            updateBuilder.set(\.$reference, to: reference)
        }
        
        if let note = content.note {
            updateBuilder.set(\.$note, to: note)
        }
        
        if let orderDate = content.orderDate {
            updateBuilder.set(\.$orderDate, to: orderDate)
        }
        
        if let deliveryDate = content.deliveryDate {
            updateBuilder.set(\.$deliveryDate, to: deliveryDate)
        }
        
        if let paymentTermsDays = content.paymentTermsDays {
            updateBuilder.set(\.$paymentTermsDays, to: paymentTermsDays)
        }
        
        if let supplierId = content.supplierId {
            updateBuilder.set(\.$supplierId, to: supplierId)
        }
        
        if let vatOption = content.vatOption {
            updateBuilder.set(\.$vatOption, to: vatOption)
        }
        
        if let items = content.poItems() {
            updateBuilder.set(\.$items, to: items)
        }
       
        if let additionalDiscountAmount = content.additionalDiscountAmount {
            updateBuilder.set(\.$additionalDiscountAmount, to: additionalDiscountAmount)
        }
        
        if let currency = content.currency {
            updateBuilder.set(\.$currency, to: currency)
        }
        
        if let includedVat = content.includedVat {
            updateBuilder.set(\.$includedVat, to: includedVat)
        }
        
//        if let vatRateOption = content.vatRateOption {
//            updateBuilder.set(\.$vatRateOption, to: vatRateOption)
//        }
//        
        
        
        /*
         struct Update: Content, Validatable {
             let reference: String?
             let note: String?
             let paymentTermsDays: Int?
             let supplierId: UUID?
             let deliveryDate: Date?
             let items: [UpdateItem]?
             let vatOption: PurchaseOrder.VatOption?
             let orderDate: Date?
             let additionalDiscountAmount: Double?
             let currency: CurrencySupported?
             let includedVat: Bool?
             let vatRateOption: VatRateOption?
         }
         */
      
        
        return updateBuilder
    }
}
/*
 enum PurchaseOrderStatus: String, Codable {
     case draft = "DRAFT"
     case pending = "PENDING"
     case approved = "APPROVED"
     case rejected = "REJECTED"
     case voided = "VOIDED"
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
     
     @Field(key: "included_vat")
     var includedVat: Bool
     
     @Field(key: "vat_rate")
     var vatRate: Double?
     
     @Field(key: "total_amount_before_discount")
     var totalAmountBeforeDiscount: Double
     
     @Field(key: "total_amount_before_vat")
     var totalAmountBeforeVat: Double
     
     @Field(key: "total_vat_amount")
     var totalVatAmount: Double?
     
     @Field(key: "total_amount_after_vat")
     var totalAmountAfterVat: Double
     
     @Field(key: "total_withholding_tax_amount")
     var totalWithholdingTaxAmount: Double?
     
     @Field(key: "total_amount_due")
     var totalAmountDue: Double
     
     @Field(key: "additional_discount_amount")
     var additionalDiscountAmount: Double

     @Enum(key: "currency")
     var currency: CurrencySupported
     
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
     
     @Timestamp(key: "pended_at",
                 on: .none,
                format: .iso8601)
     var pendedAt: Date?
     
     @Timestamp(key: "approved_at",
                on: .none,
                format: .iso8601)
     var approvedAt: Date?
     
     @Timestamp(key: "voided_at",
                on: .none,
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
          currency: CurrencySupported = .thb,
          note: String = "",
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          pendedAt: Date? = nil,
          approvedAt: Date? = nil,
          voidedAt: Date? = nil,
          logs: [ActionLog] = []) {
         self.id = id ?? .init()
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
         self.createdAt = createdAt ?? .now
         self.updatedAt = updatedAt
         self.pendedAt = pendedAt
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
     
     convenience init(id: UUID? = nil,
                      month: Int,
                      year: Int,
                      number: Int = 1,
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
                      currency: CurrencySupported = .thb,
                      note: String = "",
                      userId: UUID) {
         let actionLog: [ActionLog] = [.init(userId: userId,
                                             action: .created,
                                             date: .now)]
         self.init(id: id ?? .init(),
                   month: month,
                   year: year,
                   number: number,
                   status: .pending,
                   reference: reference,
                   vatOption: vatOption,
                   includedVat: includedVat,
                   vatRate: vatRate,
                   items: items,
                   additionalDiscountAmount: additionalDiscountAmount,
                   orderDate: orderDate,
                   deliveryDate: deliveryDate,
                   paymentTermsDays: paymentTermsDays,
                   supplierId: supplierId,
                   customerId: customerId,
                   currency: currency,
                   note: note,
                   logs: actionLog)
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
 */
