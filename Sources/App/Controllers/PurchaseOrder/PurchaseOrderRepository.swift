import Foundation
import Vapor
import Fluent

protocol PurchaseOrderRepositoryProtocol {
    func fetchAll(page: Int, 
                  offset: Int,
                  on db: Database) async throws -> [PurchaseOrder]
//    func create(content: PurchaseOrder.Create,
//                on db: Database) async throws -> PurchaseOrder
    func find(id: UUID,
              on db: Database) async throws -> PurchaseOrder
//    func update(id: UUID,
//                with content: PurchaseOrder.Update,
//                on db: Database) async throws -> PurchaseOrder
    
    func approve(id: UUID, on db: Database) async throws -> PurchaseOrder
    func reject(id: UUID, on db: Database) async throws -> PurchaseOrder
    func cancel(id: UUID, on db: Database) async throws -> PurchaseOrder

    func search(name: String, on db: Database) async throws -> [PurchaseOrder]
    func lastedItemNumber(year: Date,
                  on db: Database) async throws -> Int
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
