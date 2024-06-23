import Foundation
import Vapor
import Fluent

protocol PurchaseOrderRepositoryProtocol {
    func fetchAll(page: Int,
                  offset: Int,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func create(content: PurchaseOrderRepository.Create,
                on db: Database) async throws -> PurchaseOrder
    func find(id: UUID,
              on db: Database) async throws -> PurchaseOrder
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
    
    func search(name: String, on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func lastedItemNumber(year: Int,
                          month: Int,
                          on db: Database) async throws -> Int
}

class PurchaseOrderRepository: PurchaseOrderRepositoryProtocol {
   
    
    let stub = PurchaseOrder(month: 1,
                             year: 2024,
                             items: [],
                             supplierId: .init(),
                             customerId: .init())
    
    func fetchAll(page: Int, offset: Int, on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrder> {
        return .init(page: 1,
                     perPage: 20,
                     total: 0,
                     items: [])
    }
    
    func create(content: PurchaseOrderRepository.Create,
                on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
    }
    
    func find(id: UUID, on db: any FluentKit.Database) async throws -> PurchaseOrder {
        return self.stub
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
    
    func search(name: String, on db: any FluentKit.Database) async throws -> PaginatedResponse<PurchaseOrder> {
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

// protocol ProductCategoryRepositoryProtocol {
//     func fetchAll(showDeleted: Bool,
//                   on db: Database) async throws -> [ProductCategory]
//     func create(content: ProductCategory.Create,
//                 on db: Database) async throws -> ProductCategory
//     func find(id: UUID,
//               on db: Database) async throws -> ProductCategory
//     func find(name: String,
//               on db: Database) async throws -> ProductCategory
//     func update(id: UUID,
//                 with content: ProductCategory.Update,
//                 on db: Database) async throws -> ProductCategory
//     func delete(id: UUID, on db: Database) async throws -> ProductCategory
//     func search(name: String, on db: Database) async throws -> [ProductCategory]
// }
