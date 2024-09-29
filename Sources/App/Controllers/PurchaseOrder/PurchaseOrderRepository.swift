import Foundation
import Vapor
import Fluent
import Mockable

@Mockable
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
    
    func search(request: PurchaseOrderRequest.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    
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
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder
    
    
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
            .with(\.$supplier)
            .with(\.$customer)
        
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
        
        let query = PurchaseOrder.query(on: db)
            .with(\.$supplier)
            .with(\.$customer)
            .filter(\.$id == request.id)
        
        guard
            let found = try await query.first()
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
        try await po.create(on: db)
        
        return try await fetchById(request: .init(id: po.id!),
                                   on: db)
    }
    
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
                let updatedSupplier = try? await contactRepository.fetchById(request: .init(id: supplierId),
                                                                             on: db)
            else { throw PurchaseOrderRequest.Error.notFoundSupplierId }
            
            po.$supplier.id = supplierId
            po.$supplier.value = updatedSupplier
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
        
        //        if let items = request.items {
        //            // check all po product item ans service is exist
        //            for item in items {
        //                switch item.kind {
        //                case .product:
        //                    guard
        //                        let _ = try? await productRepository.fetchById(request: .init(id: item.itemId),
        //                                                                       on: db)
        //                    else { throw PurchaseOrderRequest.Error.notFoundProductId }
        //
        //                case .service:
        //                    guard
        //                        let _ = try? await serviceRepository.fetchById(request: .init(id: item.itemId),
        //                                                                      on: db)
        //                    else { throw PurchaseOrderRequest.Error.notFoundServiceId }
        //                }
        //            }
        //
        //            guard
        //                let poItems = request.poItems()
        //            else { throw PurchaseOrderRequest.Error.emptyItems }
        
        //            po.items = poItems
        // isChanged = true
        
        //po.recalculateItems()
        //}
        
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
    
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder {
        let po = try await fetchById(request: id,
                                     on: db)
        
        let availableStatuses = po.ableUpdateStatus()
        guard availableStatuses.contains(.voided) else {
            throw PurchaseOrderRequest.Error.notAbleToVoid
        }
        
        po.status = .voided
        po.addLog(userID: userId.id,
                  action: .voided)
        
        try await po.save(on: db)
        return po
    }
    
    func search(request: PurchaseOrderRequest.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder> {
        let q = request.query
        let regexPattern = "(?i)\(q)"  // (?i) makes the regex case-insensitive
        let query = PurchaseOrder.query(on: db)
            .with(\.$supplier)
            .with(\.$customer)
            .join(Contact.self, on: \PurchaseOrder.$supplier.$id == \Contact.$id)
            .join(MyBusinese.self, on: \PurchaseOrder.$customer.$id == \MyBusinese.$id)
            .group(.or) { or in
                or.filter(\.$reference =~ regexPattern)
                or.filter(\.$note =~ regexPattern)
                
                // Filter by supplier name (case-insensitive 'like' filter)
                or.filter(Contact.self, \Contact.$name =~ regexPattern)
                
                if let number = Int(q) {
                    or.filter(\.$number == number)
                }
                
            }.group(.and) { and in
                // filter by status
                switch request.status {
                case .approved:
                    and.filter(\.$status == PurchaseOrderStatus.approved)
                case .draft:
                    and.filter(\.$status == PurchaseOrderStatus.draft)
                case .pending:
                    and.filter(\.$status == PurchaseOrderStatus.pending)
                case .voided:
                    and.filter(\.$status == PurchaseOrderStatus.voided)
                default:
                    break
                }
                
                // filter by orderDate period
                let from = request.periodDate.from
                let to = request.periodDate.to
                
                and.filter(\.$orderDate >= from)
                and.filter(\.$orderDate <= to)
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
