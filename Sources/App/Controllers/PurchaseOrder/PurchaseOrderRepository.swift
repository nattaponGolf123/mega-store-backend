import Foundation
import Vapor
import Fluent
import Mockable

protocol PurchaseOrderRepositoryProtocol {
    func fetchAll(request: PurchaseOrderRequest.FetchAll,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func fetchById(request: GeneralRequest.FetchById,
                   on db: Database) async throws -> PurchaseOrder
    func create(request: PurchaseOrderRequest.Create,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    func update(byId: GeneralRequest.FetchById,
                request: PurchaseOrderRequest.Update,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    
    func replaceItems(id: GeneralRequest.FetchById,
                      request: PurchaseOrderRequest.ReplaceItems,
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder
 
    func itemsReorder(id: GeneralRequest.FetchById,
                      itemsOrder: [GeneralRequest.FetchById],
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder
    
    func approve(id: GeneralRequest.FetchById,
                 userId: GeneralRequest.FetchById,
                 on db: Database) async throws -> PurchaseOrder
//    func reject(id: GeneralRequest.FetchById,
//                userId: GeneralRequest.FetchById,
//                on db: Database) async throws -> PurchaseOrder
    func cancel(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder
    
    func search(request: PurchaseOrderRequest.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func fetchLastedNumber(year: Int,
                           month: Int,
                           on db: Database) async throws -> Int
}

class PurchaseOrderRepository: PurchaseOrderRepositoryProtocol {
        
    private var productRepository: ProductRepositoryProtocol
    private var serviceRepository: ServiceRepositoryProtocol
    private var myBusineseRepository: MyBusineseRepositoryProtocol
    private var contactRepository: ContactRepositoryProtocol
    private var userRepository: UserRepositoryProtocol
        
    init(productRepository: ProductRepositoryProtocol = ProductRepository(),
         serviceRepository: ServiceRepositoryProtocol = ServiceRepository(),
         myBusineseRepository: MyBusineseRepositoryProtocol = MyBusineseRepository(),
         contactRepository: ContactRepositoryProtocol = ContactRepository(),
         userRepository: UserRepositoryProtocol = UserRepository()) {
        self.productRepository = productRepository
        self.serviceRepository = serviceRepository
        self.myBusineseRepository = myBusineseRepository
        self.contactRepository = contactRepository
        self.userRepository = userRepository
    }
    
    func fetchAll(request: PurchaseOrderRequest.FetchAll,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrder> {
        let query = PurchaseOrder.query(on: db)
        
        let total = try await query.count()
        let items = try await sortQuery(query: query,
                                        sortBy: request.sortBy,
                                        sortOrder: request.sortOrder,
                                        status: request.status,
                                        periodDate: request.periodDate,
                                        page: request.page,
                                        perPage: request.perPage)
        
        let response = PaginatedResponse(page: request.page,
                                         perPage: request.perPage,
                                         total: total,
                                         items: items)
        
        return response
    }
    
    func fetchById(request: GeneralRequest.FetchById,
                   on db: Database) async throws -> PurchaseOrder {
        guard
            let found = try await PurchaseOrder.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func create(request: PurchaseOrderRequest.Create,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        
        // fetch to check userId is exist
        guard
            let _ = try? await userRepository.fetchById(request: userId,
                                                        on: db)
        else { throw PurchaseOrderRequest.Error.notfoundUserId }
        
        // fetch to check is exist supplier
        let supplierId = request.supplierId
        guard
            let _ = try? await contactRepository.fetchById(request: .init(id: supplierId),
                                                           on: db)
        else { throw PurchaseOrderRequest.Error.notFoundSupplierId }
                
        // fetch to check is exist customer
        let customerId = request.customerId
        guard
            let _ = try? await myBusineseRepository.fetchById(request: .init(id: customerId),
                                                              on: db)
        else { throw PurchaseOrderRequest.Error.notFoundCustomerId }
        
        // check all po product item ans service is exist
        for item in request.items {
            switch item.kind {
            case .product:
                guard
                    let _ = try? await productRepository.fetchById(request: .init(id: item.itemId),
                                                                   on: db)
                else { throw PurchaseOrderRequest.Error.notFoundProductId }
                
            case .service:
                guard
                    let _ = try? await serviceRepository.fetchById(request: .init(id: item.itemId),
                                                                  on: db)
                else { throw PurchaseOrderRequest.Error.notFoundServiceId }
            }
        }
        
        let year = request.yearNumber()
        let month = request.monthNumber()
        let lastedNumber = try await fetchLastedNumber(year: year,
                                                       month: month,
                                                       on: db)
        let nextNumber = lastedNumber + 1
        
        let po = PurchaseOrder(month: month,
                               year: year,
                               number: nextNumber,
                               reference: request.reference,
                               vatOption: request.vatOption,
                               includedVat: request.includedVat,
                               items: request.poItems(),
                               additionalDiscountAmount: request.additionalDiscountAmount,
                               orderDate: request.orderDate,
                               deliveryDate: request.deliveryDate,
                               paymentTermsDays: request.paymentTermsDays,
                               supplierId: supplierId,
                               customerId: customerId,
                               currency: request.currency,
                               note: request.note,
                               userId: userId.id)
        try await po.save(on: db)
        return po
    }
    
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
         
         init(reference: String?,
              note: String?,
              paymentTermsDays: Int?,
              supplierId: UUID?,
              deliveryDate: Date?,
              items: [UpdateItem]?,
              vatOption: PurchaseOrder.VatOption?,
              orderDate: Date?,
              additionalDiscountAmount: Double?,
              currency: CurrencySupported?,
              includedVat: Bool?) {
             self.reference = reference
             self.note = note
             self.paymentTermsDays = paymentTermsDays
             self.supplierId = supplierId
             self.deliveryDate = deliveryDate
             self.items = items
             self.vatOption = vatOption
             self.orderDate = orderDate
             self.additionalDiscountAmount = additionalDiscountAmount
             self.currency = currency
             self.includedVat = includedVat
         }
     }
     */
    func update(byId: GeneralRequest.FetchById,
                request: PurchaseOrderRequest.Update,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: .init(id: byId.id),
                                          on: db)
        
        var isChanged: Bool = false
        
        if let reference = request.reference {
            po.reference = reference
            isChanged = true
        }
        
        if let note = request.note {
            po.note = note
            isChanged = true
        }
        
        if let paymentTermsDays = request.paymentTermsDays {
            po.paymentTermsDays = paymentTermsDays
            isChanged = true
        }
        
        if let supplierId = request.supplierId {
            // check is exist supplier
            guard
                let _ = try? await contactRepository.fetchById(request: .init(id: supplierId),
                                                               on: db)
            else { throw PurchaseOrderRequest.Error.notFoundSupplierId }
            
            po.$supplier.id = supplierId
            isChanged = true
        }
        
        if let deliveryDate = request.deliveryDate {
            po.deliveryDate = deliveryDate
            isChanged = true
        }
        
        if let vatOption = request.vatOption {
            po.vatOption = vatOption
            isChanged = true
        }
        
        if let orderDate = request.orderDate {
            po.orderDate = orderDate
            isChanged = true
        }
        
        if let additionalDiscountAmount = request.additionalDiscountAmount {
            po.additionalDiscountAmount = additionalDiscountAmount
            isChanged = true
            
            po.recalculateItems()
        }
        
        if let currency = request.currency {
            po.currency = currency
            isChanged = true
            
            po.recalculateItems()
        }
        
        if let includedVat = request.includedVat {
            po.includedVat = includedVat
            isChanged = true
            
            po.recalculateItems()
        }
        
        if let items = request.items {
            // check all po product item ans service is exist
            for item in items {
                switch item.kind {
                case .product:
                    guard
                        let _ = try? await productRepository.fetchById(request: .init(id: item.itemId),
                                                                       on: db)
                    else { throw PurchaseOrderRequest.Error.notFoundProductId }
                    
                case .service:
                    guard
                        let _ = try? await serviceRepository.fetchById(request: .init(id: item.itemId),
                                                                      on: db)
                    else { throw PurchaseOrderRequest.Error.notFoundServiceId }
                }
            }
            
            guard
                let poItems = request.poItems()
            else { throw PurchaseOrderRequest.Error.emptyItems }
            
            po.items = poItems
            isChanged = true
            
            po.recalculateItems()
        }
        
        // append new logs
        if isChanged {
            po.addLog(userID: userId.id,
                      action: .updated)
        }
                        
        try await po.save(on: db)
        
        return po
    }
    
    func replaceItems(id: GeneralRequest.FetchById,
                      request: PurchaseOrderRequest.ReplaceItems,
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: id,
                                          on: db)
        
        // check all po product item ans service is exist
        let items = request.items
        // check all po product item ans service is exist
        for item in items {
            switch item.kind {
            case .product:
                guard
                    let _ = try? await productRepository.fetchById(request: .init(id: item.itemId),
                                                                   on: db)
                else { throw PurchaseOrderRequest.Error.notFoundProductId }
                
            case .service:
                guard
                    let _ = try? await serviceRepository.fetchById(request: .init(id: item.itemId),
                                                                   on: db)
                else { throw PurchaseOrderRequest.Error.notFoundServiceId }
            }
        }
        
        po.includedVat = request.includedVat
        po.vatOption = request.vatOption
        po.additionalDiscountAmount = request.additionalDiscountAmount
        po.items = request.poItems()
        
        po.recalculateItems()

        // append new logs
        po.addLog(userID: userId.id,
                  action: .updated)
                        
        try await po.save(on: db)
        
        return po
        
    }
 
    func itemsReorder(id: GeneralRequest.FetchById,
                      itemsOrder: [GeneralRequest.FetchById],
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder {
        
        let po = try await fetchById(request: id,
                                     on: db)
        //check is all match item id
        let itemOrderIds: [UUID] = itemsOrder.map({ $0.id })
        let poItemIds: [UUID] = po.items.compactMap({ $0.id })
        
        guard
            Set(itemOrderIds) == Set(poItemIds)
        else { throw PurchaseOrderRequest.Error.notMatchItems }
        
        //reorder item by match of itemOrderIds order uuid
        po.items = itemOrderIds.compactMap({ poItemId in
            po.items.first(where: { $0.id == poItemId })
        })
        
        try await po.save(on: db)
        return po
    }
    
    func approve(id: GeneralRequest.FetchById,
                 userId: GeneralRequest.FetchById,
                 on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: id,
                                          on: db)
        
        let availableStatuses = po.ableUpdateStatus()
        guard availableStatuses.contains(.approved) else {
            throw PurchaseOrderRequest.Error.notAbleToApprove
        }
        
        po.status = .approved
        po.addLog(userID: userId.id,
                  action: .approved)
        
        try await po.save(on: db)
        return po
    }
    
//    func reject(id: GeneralRequest.FetchById,
//                userId: GeneralRequest.FetchById,
//                on db: Database) async throws -> PurchaseOrder {
//        .Stub.po1
//    }
//    
    func cancel(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: id,
                                          on: db)
        
        let availableStatuses = po.ableUpdateStatus()
        guard availableStatuses.contains(.voided) else {
            throw PurchaseOrderRequest.Error.notAbleToCancel
        }
        
        po.status = .approved
        po.addLog(userID: userId.id,
                  action: .approved)
        
        try await po.save(on: db)
        return po
    }
    
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: id,
                                          on: db)
        
        let availableStatuses = po.ableUpdateStatus()
        guard availableStatuses.contains(.approved) else {
            throw PurchaseOrderRequest.Error.notAbleToVoid
        }
        
        po.status = .approved
        po.addLog(userID: userId.id,
                  action: .approved)
        
        try await po.save(on: db)
        return po
    }
    
    /*
     struct Search: Content, Validatable{
         let query: String
         let page: Int
         let perPage: Int
         let status: Status
         let sortBy: SortBy
         let sortOrder: SortOrder
         let periodDate: PeriodDate

         static let minPageRange: (min: Int, max: Int) = (1, .max)
         static let perPageRange: (min: Int, max: Int) = (20, 1000)
         
         init(query: String,
              page: Int = Self.minPageRange.min,
              perPage: Int = Self.perPageRange.min,
              status: Status = .all,
              sortBy: SortBy = .createdAt,
              sortOrder: SortOrder = .asc,
              periodDate: PeriodDate) {
             self.query = query
             self.page = min(max(page, Self.minPageRange.min), Self.minPageRange.max)
             self.perPage = min(max(perPage, Self.perPageRange.min), Self.perPageRange.max)
             self.status = status
             self.sortBy = sortBy
             self.sortOrder = sortOrder
             self.periodDate = periodDate
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.query = try container.decode(String.self, forKey: .query)
             self.page = (try? container.decode(Int.self, forKey: .page)) ?? Self.minPageRange.min
             self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? Self.perPageRange.min
             self.status = (try? container.decode(Status.self, forKey: .status)) ?? .all
             self.sortBy = (try? container.decodeIfPresent(SortBy.self, forKey: .sortBy)) ?? .createdAt
             self.sortOrder = (try? container.decodeIfPresent(SortOrder.self, forKey: .sortOrder)) ?? .asc
             
             let dateFormat = "yyyy-MM-dd"
             let from = try container.decode(String.self, forKey: .from).tryToDate(dateFormat)
             let to = try container.decode(String.self, forKey: .to).tryToDate(dateFormat)
             self.periodDate = .init(from: from,
                                     to: to)
         }

         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(query, forKey: .query)
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
             case query = "q"
             case page
             case perPage = "per_page"
             case sortBy = "sort_by"
             case sortOrder = "sort_order"
             case status
             case from
             case to
         }
     }
     */
    func search(request: PurchaseOrderRequest.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder> {
        let q = request.query
        let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
        let query = PurchaseOrder.query(on: db)
            .join(Contact.self, on: \PurchaseOrder.$supplier.$id == \Contact.$id)
            .join(MyBusinese.self, on: \PurchaseOrder.$customer.$id == \MyBusinese.$id)
            .group(.or) { or in
                or.filter(\.$reference =~ regexPattern)
                or.filter(\.$note =~ regexPattern)
                
                //or.filter(\.$supplier, Contact.self, \.$name =~ regexPattern)
                //or.filter(\.$supplier.$name =~ regexPattern)
                
                // Perform a join to the Supplier model (related through the `supplier` relationship)
                //query.join(Contact.self, on: \PurchaseOrder.$supplier.$id == \Contact.$id)
                
                // Add filter for supplier name (case-insensitive 'like' filter)
                or.filter(Contact.self, \.$name =~ regexPattern)
                
                if let number = Int(q) {
                    or.filter(\.$number == number)
                }
                
                // filter by status
                switch request.status {
                case .approved:
                    or.filter(\.$status == PurchaseOrderStatus.approved)
                case .draft:
                    or.filter(\.$status == PurchaseOrderStatus.draft)
                case .pending:
                    or.filter(\.$status == PurchaseOrderStatus.pending)
                case .voided:
                    or.filter(\.$status == PurchaseOrderStatus.voided)
                default:
                    break
                }
                
                // filter by orderDate period
                let from = request.periodDate.from
                let to = request.periodDate.to
                
                or.filter(\.$orderDate >= from)
                or.filter(\.$orderDate <= to)
            }
        
        let total = try await query.count()
        
        let items = try await sortQuery(query: query,
                                        sortBy: request.sortBy,
                                        sortOrder: request.sortOrder,
                                        status: request.status,
                                        periodDate: request.periodDate,
                                        page: request.page,
                                        perPage: request.perPage)
        
        let response = PaginatedResponse(page: request.page,
                                         perPage: request.perPage,
                                         total: total,
                                         items: items)
        
        return response
    }
    
    func fetchLastedNumber(year: Int,
                           month: Int,
                           on db: Database) async throws -> Int {
        let query = PurchaseOrder.query(on: db)
        query.sort(\.$number, .descending)
        query.limit(1)
        
        let model = try await query.first()
        
        return model?.number ?? 0
    }
   
//    typealias CreateContent = PurchaseOrderRequest.Create
//    
//    private var productRepository: ProductRepositoryProtocol
//    private var serviceRepository: ServiceRepositoryProtocol
//    private var myBusineseRepository: MyBusineseRepositoryProtocol
//    private var contactRepository: ContactRepositoryProtocol
//    
//    let stub = PurchaseOrder(month: 1,
//                             year: 2024,
//                             vatOption: .noVat,
//                             includedVat: false,
//                             items: [],
//                             supplierId: .init(),
//                             customerId: .init())
//    
//    init(productRepository: ProductRepositoryProtocol = ProductRepository(),
//         serviceRepository: ServiceRepositoryProtocol = ServiceRepository(),
//         myBusineseRepository: MyBusineseRepositoryProtocol = MyBusineseRepository(),
//         contactRepository: ContactRepositoryProtocol = ContactRepository()) {
//        self.productRepository = productRepository
//        self.serviceRepository = serviceRepository
//        self.myBusineseRepository = myBusineseRepository
//        self.contactRepository = contactRepository
//    }
//    
//    func all(content: PurchaseOrderRequest.Fetch,
//             on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrderResponse> {
//        do {
//            let page = content.page
//            let perPage = content.perPage
//            let from = content.periodDate.from
//            let to = content.periodDate.to
//            
//            guard
//                page > 0,
//                perPage > 0
//            else { throw DefaultError.invalidInput }
//            
//            let query = queryBuilder(from: from,
//                                     to: to,
//                                     status: content.purchaseOrderStatus(),
//                                     on: db)
//            
//            let total = try await query.count()
//            
//            //query sorted by name
//            let items = try await sortQuery(query: query,
//                                            sortBy: content.sortBy,
//                                            sortOrder: content.sortOrder,
//                                            status: content.status,
//                                            periodDate: content.periodDate,
//                                            page: page,
//                                            perPage: perPage)
//            let itemResponses: [PurchaseOrderResponse] = items.map { PurchaseOrderResponse(po: $0) }
//            
//            let response = PaginatedResponse(page: page,
//                                             perPage: perPage,
//                                             total: total,
//                                             items: itemResponses)
//            
//            return response
//        } catch {
//            // Handle all other errors
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func create(content: PurchaseOrderRequest.Create,
//                userId: UUID,
//                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        do {
//            // validate exist supplierId , customerId
//           
//            guard
//                let _ = try? await contactRepository.fetchById(request: .init(id: content.supplierId),
//                                                               on: db),
//                let customerId = try? await myBusineseRepository.fetchAll(on: db).first?.id
//            else {
//                throw DefaultError.error(message: "supplier or customer not found")
//            }
//            
//            
//            // validate exist productId
////            do {
////                for uuid in content.productUUIDs() {
////                    let _ = try await productRepository.find(id: uuid, on: db)
////                }
////            } catch {
////                throw DefaultError.error(message: "product not found")
////            }
//            
//            // validate exist serviceId
//            do {
//                for uuid in content.serviceUUIDs() {
//                    let _ = try await serviceRepository.fetchById(request: .init(id: uuid),
//                                                                  on: db)
//                }
//            } catch {
//                throw DefaultError.error(message: "service not found")
//            }
//            
//            let yearNumber = content.yearNumber()
//            let monthNumber = content.monthNumber()
//            let lastedNumber = try await fetchLastedNumber(year: content.yearNumber(),
//                                                           month: content.monthNumber(),
//                                                           on: db)
//            let nextNumber = lastedNumber + 1
//            
//            let poItems = content.poItems()
//            let newModel = PurchaseOrder(month: monthNumber,
//                                         year: yearNumber,
//                                         number: nextNumber,
//                                         reference: content.reference,
//                                         vatOption: content.vatOption,
//                                         includedVat: content.includedVat,
//                                         items: poItems,
//                                         additionalDiscountAmount: content.additionalDiscountAmount,
//                                         orderDate: content.orderDate,
//                                         deliveryDate: content.deliveryDate,
//                                         paymentTermsDays: content.paymentTermsDays,
//                                         supplierId: content.supplierId,
//                                         customerId: customerId,
//                                         currency: content.currency,
//                                         note: content.note,
//                                         userId: userId)
//            
//            try await newModel.save(on: db)
//            
//            return PurchaseOrderResponse(po: newModel)
//        } catch {
//            throw DefaultError.error(message: error.localizedDescription)
//        }
//    }
//    
//    func find(id: UUID,
//              on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        guard
//            let model = try await PurchaseOrder.query(on: db).filter(\.$id == id).first()
//        else { throw DefaultError.notFound }
//        
//        return PurchaseOrderResponse(po: model)
//    }
//    
//   
//    func update(id: UUID,
//                with content: PurchaseOrderRequest.Update,
//                userId: UUID,
//                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        guard
//            let model = try await PurchaseOrder.query(on: db).filter(\.$id == id).first()
//        else { throw DefaultError.notFound }
//        
//        // validate exist supplierId , customerId
//        if let supplierId = content.supplierId {            
//            guard
//                let _ = try? await contactRepository.fetchById(request: .init(id: supplierId),
//                                                               on: db)
//            else {
//                throw DefaultError.error(message: "supplier not found")
//            }
//            
//            model.supplierId = supplierId
//        }
//        
//        if let reference = content.reference {
//            model.reference = reference
//        }
//        
//        if let note = content.note {
//            model.note = note
//        }
//        
//        if let paymentTermsDays = content.paymentTermsDays {
//            model.paymentTermsDays = paymentTermsDays
//        }
//        
//        if let deliveryDate = content.deliveryDate {
//            model.deliveryDate = deliveryDate
//        }
//        
//        if let currency = content.currency {
//            model.currency = currency
//        }
//        
//        
//        // should validate not over then delivery date
//        if let orderDate = content.orderDate,
//           orderDate <= model.deliveryDate {
//            model.orderDate = orderDate
//        }
//                
//        
//        if let productUUIDS = content.productUUIDs() {
//            // validate exist productId
////            do {
////                for uuid in productUUIDS {
////                    let _ = try await productRepository.find(id: uuid, on: db)
////                }
////            } catch {
////                throw DefaultError.error(message: "product not found")
////            }
//        }
//        
//        if let serviceUUIDs = content.serviceUUIDs() {
//            // validate exist serviceId
//            do {
//                for uuid in serviceUUIDs {
//                    let _ = try await serviceRepository.fetchById(request: .init(id: uuid),
//                                                                  on: db)
//                }
//            } catch {
//                throw DefaultError.error(message: "service not found")
//            }
//        }
//        
//       let poItems = content.poItems()
//        
//        if let includedVat = content.includedVat {
//            model.includedVat = includedVat
//            
//            // need to call re-calculate items
//            if poItems == nil {
//                model.recalculateItems()
//            }
//        }
//        
//        if let items = poItems {
//            model.replaceItems(items: items)
//        }
//        
//        
//        // update and validate
//        try await model.save(on: db)
//        
//        return PurchaseOrderResponse(po: model)
//    }
//    
//    func replaceItems(id: UUID,
//                      userId: UUID,
//                      with content: ReplaceItems, on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func approve(id: UUID,
//                 userId: UUID,
//                 on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func reject(id: UUID, 
//                userId: UUID,
//                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func cancel(id: UUID, 
//                userId: UUID,
//                on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func void(id: UUID,
//              userId: UUID,
//              on db: Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func replaceItems(id: UUID, 
//                      with content: ReplaceItems,
//                      userId: UUID,
//                      on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func itemsReorder(id: UUID,
//                      userId: UUID,
//                      itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrderResponse {
//        return .init(po: stub)
//    }
//    
//    func search(content: PurchaseOrderRequest.Search,
//                on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrderResponse> {
//        return .init(page: 1,
//                     perPage: 20,
//                     total: 0,
//                     items: [])
//    }
//    
//    func fetchLastedNumber(year: Int,
//                           month: Int,
//                           on db: Database) async throws -> Int {
//        // fetch PurchaseOrder with match "year" , "month"
//        let query = PurchaseOrder.query(on: db).filter(\.$year == year).filter(\.$month == month)
//        query.sort(\.$number, .descending)
//        query.limit(1)
//        
//        let model = try await query.first()
//        
//        return model?.number ?? 0
//    }
    
}

//private extension PurchaseOrderRepository {
//    
//    //query with 'from' date "yyyy-MM-dd" to date 'yyyy-MM-dd' and filter with status?
//    func queryBuilder(from: Date,
//                      to: Date,
//                      status: PurchaseOrderStatus?,
//                      on db: any FluentKit.Database) -> QueryBuilder<PurchaseOrder> {
//        var query = PurchaseOrder.query(on: db)
//            .filter(\.$orderDate >= from)
//            .filter(\.$orderDate <= to)
//        
//        if let status = status {
//            query = query.filter(\.$status == status)
//        }
//        
//        return query
//    }
//    
//    func sortQuery(query: QueryBuilder<PurchaseOrder>,
//                   sortBy: PurchaseOrderRequest.SortBy,
//                   sortOrder: PurchaseOrderRequest.SortOrder,
//                   status: PurchaseOrderRequest.Status,
//                   periodDate: PeriodDate,
//                   page: Int,
//                   perPage: Int) async throws -> [PurchaseOrder] {
//        switch sortBy {
//        case .status:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$status).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$status, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .createdAt:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .number:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$number).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$number, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .totalAmount:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$totalAmountDue).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$totalAmountDue, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .supplierId:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$supplierId).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$supplierId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        case .orderDate:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$orderDate).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$orderDate, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
//        }
//    }
//    
//    static func updateFieldsBuilder(uuid: UUID, 
//                                    content: PurchaseOrderRequest.Update,
//                                    db: Database) -> QueryBuilder<PurchaseOrder> {
//        let updateBuilder = PurchaseOrder.query(on: db).filter(\.$id == uuid)
//        
//        if let reference = content.reference {
//            updateBuilder.set(\.$reference, to: reference)
//        }
//        
//        if let note = content.note {
//            updateBuilder.set(\.$note, to: note)
//        }
//        
//        if let orderDate = content.orderDate {
//            updateBuilder.set(\.$orderDate, to: orderDate)
//        }
//        
//        if let deliveryDate = content.deliveryDate {
//            updateBuilder.set(\.$deliveryDate, to: deliveryDate)
//        }
//        
//        if let paymentTermsDays = content.paymentTermsDays {
//            updateBuilder.set(\.$paymentTermsDays, to: paymentTermsDays)
//        }
//        
//        if let supplierId = content.supplierId {
//            updateBuilder.set(\.$supplierId, to: supplierId)
//        }
//        
//        if let vatOption = content.vatOption {
//            updateBuilder.set(\.$vatOption, to: vatOption)
//        }
//        
//        if let items = content.poItems() {
//            updateBuilder.set(\.$items, to: items)
//        }
//       
//        if let additionalDiscountAmount = content.additionalDiscountAmount {
//            updateBuilder.set(\.$additionalDiscountAmount, to: additionalDiscountAmount)
//        }
//        
//        if let currency = content.currency {
//            updateBuilder.set(\.$currency, to: currency)
//        }
//        
//        if let includedVat = content.includedVat {
//            updateBuilder.set(\.$includedVat, to: includedVat)
//        }
//        
////        if let vatRateOption = content.vatRateOption {
////            updateBuilder.set(\.$vatRateOption, to: vatRateOption)
////        }
////        
//        
//        
//        /*
//         struct Update: Content, Validatable {
//             let reference: String?
//             let note: String?
//             let paymentTermsDays: Int?
//             let supplierId: UUID?
//             let deliveryDate: Date?
//             let items: [UpdateItem]?
//             let vatOption: PurchaseOrder.VatOption?
//             let orderDate: Date?
//             let additionalDiscountAmount: Double?
//             let currency: CurrencySupported?
//             let includedVat: Bool?
//             let vatRateOption: VatRateOption?
//         }
//         */
//      
//        
//        return updateBuilder
//    }
//}

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
                   sortBy: SortBy,
                   sortOrder: SortOrder,
                   status: PurchaseOrderRequest.Status,
                   periodDate: PeriodDate,
                   page: Int,
                   perPage: Int) async throws -> [PurchaseOrder] {
        let pageIndex = (page - 1)
        let pageStart = pageIndex * perPage
        let pageEnd = pageStart + perPage
        
        let range = pageStart..<pageEnd
        
        query.with(\.$supplier)
        query.with(\.$customer)
        
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
//        case .supplierId:
//            switch sortOrder {
//            case .asc:
//                return try await query.sort(\.$supplierId).range((page - 1) * perPage..<(page * perPage)).all()
//            case .desc:
//                return try await query.sort(\.$supplierId, .descending).range((page - 1) * perPage..<(page * perPage)).all()
//            }
        case .orderDate:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$orderDate).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$orderDate, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        default:
            return try await query.range(range).all()
        }
    }
}
