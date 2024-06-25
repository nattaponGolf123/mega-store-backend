import Foundation
import Vapor
import Fluent

protocol PurchaseOrderRepositoryProtocol {
    func all(req: PurchaseOrderRepository.Fetch,
             on db: Database) async throws -> PaginatedResponse<PurchaseOrderResponse>
    func create(content: PurchaseOrderRepository.Create,
                on db: Database) async throws -> PurchaseOrder
    func find(id: UUID,
              on db: Database) async throws -> PurchaseOrderResponse
    func update(id: UUID,
                with content: PurchaseOrderRepository.Update,
                on db: Database) async throws -> PurchaseOrder
    func replaceItems(id: UUID,
                      with content: PurchaseOrderRepository.ReplaceItems,
                      on db: Database) async throws -> PurchaseOrder
    
    func approve(id: UUID, on db: Database) async throws -> PurchaseOrder
    func reject(id: UUID, on db: Database) async throws -> PurchaseOrder
    func cancel(id: UUID, on db: Database) async throws -> PurchaseOrder
    func void(id: UUID, on db: Database) async throws -> PurchaseOrder
    
    func replaceItems(id: UUID, items: [PurchaseOrderItem], on db: Database) async throws -> PurchaseOrder
    func itemsReorder(id: UUID, itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrder
    
    func search(q: String,
                offset: Int,
                status: PurchaseOrderRepository.Status,
                sortBy: PurchaseOrderRepository.SortBy,
                sortOrder: PurchaseOrderRepository.SortOrder,
                periodDate: PeriodDate,
                on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func lastedItemNumber(year: Int,
                          month: Int,
                          on db: Database) async throws -> Int
}

class PurchaseOrderRepository: PurchaseOrderRepositoryProtocol {
    
    
    let stub = PurchaseOrder(month: 1,
                             year: 2024,
                             vatOption: .noVat,
                             includedVat: false,
                             vatRate: ._7,
                             items: [],
                             supplierId: .init(),
                             customerId: .init())
    
    func all(req: PurchaseOrderRepository.Fetch,
             on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrderResponse> {
        do {
            let page = req.page
            let perPage = req.perPage
            let from = req.periodDate.from
            let to = req.periodDate.to
            
            guard
                page > 0,
                perPage > 0
            else { throw DefaultError.invalidInput }
            
            let query = queryBuilder(from: from,
                                     to: to,
                                     status: req.purchaseOrderStatus(),
                                     on: db)
                        
            let total = try await query.count()
            
            //query sorted by name
            let items = try await sortQuery(query: query,
                                            sortBy: req.sortBy,
                                            sortOrder: req.sortOrder,
                                            status: req.status,
                                            periodDate: req.periodDate,
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
                on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func find(id: UUID, on db: any FluentKit.Database) async throws -> PurchaseOrderResponse {
        guard
            let model = try await PurchaseOrder.query(on: db).filter(\.$id == id).first()
        else { throw DefaultError.notFound }
        
        return PurchaseOrderResponse(po: model)
    }
    
    func update(id: UUID, with content: PurchaseOrderRepository.Update, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func replaceItems(id: UUID, with content: ReplaceItems, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func approve(id: UUID, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func reject(id: UUID, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func cancel(id: UUID, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func void(id: UUID, on db: Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func replaceItems(id: UUID, items: [PurchaseOrderItem], on db: Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func itemsReorder(id: UUID, itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func search(q: String,
                offset: Int,
                status: PurchaseOrderRepository.Status,
                sortBy: PurchaseOrderRepository.SortBy,
                sortOrder: PurchaseOrderRepository.SortOrder,
                periodDate: PeriodDate,
                on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrder> {
        return .init(page: 1,
                     perPage: 20,
                     total: 0,
                     items: [])
    }
    
    func lastedItemNumber(year: Int,
                          month: Int,
                          on db: any FluentKit.Database) async throws -> Int {
        return 1
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
}
