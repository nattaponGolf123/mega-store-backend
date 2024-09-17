import Foundation
import Vapor
import Fluent
import Mockable

protocol PurchaseOrderRepositoryProtocol {
    func fetchAll(content: PurchaseOrderRequest.Fetch,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func fetchById(request: GeneralRequest.FetchById,
                   on db: Database) async throws -> PurchaseOrder
    func create(content: PurchaseOrderRequest.Create,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    func update(byId: GeneralRequest.FetchById,
                request: PurchaseOrderRequest.Update,
                on db: Database) async throws -> PurchaseOrder
    
    func replaceItems(id: GeneralRequest.FetchById,
                      with content: PurchaseOrderRequest.ReplaceItems,
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder
 
    func itemsReorder(id: GeneralRequest.FetchById,
                      userId: GeneralRequest.FetchById,
                      itemsOrder: [GeneralRequest.FetchById],
                      on db: Database) async throws -> PurchaseOrder
    
    func approve(id: GeneralRequest.FetchById,
                 userId: GeneralRequest.FetchById,
                 on db: Database) async throws -> PurchaseOrder
    func reject(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    func cancel(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder
    
    func search(content: PurchaseOrderRequest.Search,
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
        
    init(productRepository: ProductRepositoryProtocol = ProductRepository(),
         serviceRepository: ServiceRepositoryProtocol = ServiceRepository(),
         myBusineseRepository: MyBusineseRepositoryProtocol = MyBusineseRepository(),
         contactRepository: ContactRepositoryProtocol = ContactRepository()) {
        self.productRepository = productRepository
        self.serviceRepository = serviceRepository
        self.myBusineseRepository = myBusineseRepository
        self.contactRepository = contactRepository
    }
    
    func fetchAll(content: PurchaseOrderRequest.Fetch,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrder> {
        .init(page: 0, perPage: 0, total: 0, items: [])
    }
    
    func fetchById(request: GeneralRequest.FetchById,
                   on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func create(content: PurchaseOrderRequest.Create,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func update(byId: GeneralRequest.FetchById,
                request: PurchaseOrderRequest.Update,
                on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func replaceItems(id: GeneralRequest.FetchById,
                      with content: PurchaseOrderRequest.ReplaceItems,
                      userId: GeneralRequest.FetchById,
                      on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
 
    func itemsReorder(id: GeneralRequest.FetchById,
                      userId: GeneralRequest.FetchById,
                      itemsOrder: [GeneralRequest.FetchById],
                      on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func approve(id: GeneralRequest.FetchById,
                 userId: GeneralRequest.FetchById,
                 on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func reject(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func cancel(id: GeneralRequest.FetchById,
                userId: GeneralRequest.FetchById,
                on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func void(id: GeneralRequest.FetchById,
              userId: GeneralRequest.FetchById,
              on db: Database) async throws -> PurchaseOrder {
        .Stub.po1
    }
    
    func search(content: PurchaseOrderRequest.Search,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder> {
        .init(page: 0, perPage: 0, total: 0, items: [])
    }
    
    func fetchLastedNumber(year: Int,
                           month: Int,
                           on db: Database) async throws -> Int {
        0
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

private extension ServiceRepository {
    
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
