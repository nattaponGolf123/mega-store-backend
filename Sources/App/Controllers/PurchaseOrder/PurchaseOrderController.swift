import Foundation
import Fluent
import Vapor

class PurchaseOrderController: RouteCollection {
    typealias CreateContent = PurchaseOrderRepository.Create
    typealias UpdateContent = PurchaseOrderRepository.Update
    
    private(set) var repository: PurchaseOrderRepositoryProtocol
    private(set) var validator: PurchaseOrderValidatorProtocol
    
    init(repository: PurchaseOrderRepositoryProtocol = PurchaseOrderRepository(),
         validator: PurchaseOrderValidatorProtocol = PurchaseOrderValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        let groups = routes.grouped("purchase_orders")
        groups.get(use: all)
        groups.post(use: create)
        
        groups.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            
            withID.group("void") { withVoid in
                withVoid.post(use: void)
            }
            
            withID.group("cancel") { withVoid in
                withVoid.post(use: cancel)
            }
            
            withID.group("approve") { withVoid in
                withVoid.post(use: approve)
            }
            
            withID.group("reject") { withVoid in
                withVoid.post(use: reject)
            }
            
            withID.group("replace_items") { withReplaceItem in
                withReplaceItem.put(use: replaceItems)
            }
            
            withID.group("reorder_items") { withReorderItem in
                withReorderItem.put(use: reorderItems)
            }
        }
        
        groups.group("search") { withSearch in
            withSearch.get(use: search)
        }
    }
    
    // GET /purchase_orders?page=1&per_page=10&status=all&sort_by=created_at&sort_order=asc&fromt=2024-01-01&to=2024-12-31
    func all(req: Request) async throws -> PaginatedResponse<PurchaseOrder> {
        //let fetch = try req.content.decode(PurchaseOrderRepository.Fetch.self)
        
        let content: PurchaseOrderRepository.Fetch = try validator.validateFetchQuery(req)
        
        return try await repository.all(page: content.page,
                                       offset: content.perPage,
                                       status: content.status,
                                       sortBy: content.sortBy,
                                       sortOrder: content.sortOrder,
                                       periodDate: content.periodDate,
                                       on: req.db)
    }
    
    // GET /purchase_orders/:id
    func getByID(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        
        return try await repository.find(id: uuid, on: req.db)
    }

    // POST /purchase_orders   
    func create(req: Request) async throws -> PurchaseOrder {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(content: content,
                                           on: req.db)
    }
    
    // PUT /purchase_orders/:id
    func update(req: Request) async throws -> PurchaseOrder {
        let (uuid, content) = try validator.validateUpdate(req)
        
        return try await repository.update(id: uuid,
                                           with: content,
                                           on: req.db)
    }
    
    // POST /purchase_orders/:id/approve
    func approve(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        return try await repository.approve(id: uuid,
                                            on: req.db)
    }
    
    // POST /purchase_orders/:id/reject
    func reject(req: Request) async throws -> PurchaseOrder {        
        let uuid = try validator.validateID(req)
        return try await repository.reject(id: uuid,
                                           on: req.db)
    }
    
    // POST /purchase_orders/:id/cancel
    func cancel(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        return try await repository.cancel(id: uuid,
                                          on: req.db)
    }
    
    // POST /purchase_orders/:id/void
    func void(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        return try await repository.void(id: uuid,
                                        on: req.db)
    }
    
    // PUT /purchase_orders/:id/replace_items
    func replaceItems(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        let content = try req.content.decode(PurchaseOrderRepository.ReplaceItems.self)
        
        return try await repository.replaceItems(id: uuid,
                                                with: content,
                                                on: req.db)
    }
    
    // PUT /purchase_orders/:id/reorder_items
    func reorderItems(req: Request) async throws -> PurchaseOrder {
        let uuid = try validator.validateID(req)
        let content = try req.content.decode(PurchaseOrderRepository.ReorderItems.self)
        
        return try await repository.itemsReorder(id: uuid,
                                                 itemsOrder: content.itemIdOrder,
                                                 on: req.db)
    }
    
    // GET /purchase_orders/search?q=xxx
    func search(req: Request) async throws -> PaginatedResponse<PurchaseOrder> {
        let content = try validator.validateSearchQuery(req)
        
        return try await repository.search(q: content.q,
                                           offset: content.page,
                                           status: content.status,
                                           sortBy: content.sortBy,
                                           sortOrder: content.sortOrder,
                                           periodDate: content.periodDate,
                                           on: req.db)
    }
        
    
    
}
    /*
    
   
protocol PurchaseOrderRepositoryProtocol {
    func all(page: Int,
                  offset: Int,
                  status: PurchaseOrderRepository.Status,
                  sortBy: PurchaseOrderRepository.SortBy,
                  sortOrder: PurchaseOrderRepository.SortOrder,
                  periodDate: PeriodDate,
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
    
    func replaceItems(id: UUID, items: [PurchaseOrderItem], on db: Database) async throws -> PurchaseOrder
    func itemsReorder(id: UUID, itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrder
    
    func search(name: String, on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
    func lastedItemNumber(year: Int,
                          month: Int,
                          on db: Database) async throws -> Int
}

     */
    /*
     class ProductController: RouteCollection {
     
     private(set) var repository: ProductRepositoryProtocol
     private(set) var validator: ProductValidatorProtocol
     
     init(repository: ProductRepositoryProtocol = ProductRepository(),
     validator: ProductValidatorProtocol = ProductValidator()) {
     self.repository = repository
     self.validator = validator
     }
     
     func boot(routes: RoutesBuilder) throws {
     
     let groups = routes.grouped("products")
     groups.get(use: all)
     groups.post(use: create)
     
     groups.group(":id") { withID in
     withID.get(use: getByID)
     withID.put(use: update)
     withID.delete(use: delete)
     
     withID.group("variants") { withVariant in
     withVariant.post(use: createVariant)
     
     withVariant.group(":variant_id") { withVariantID in
     withVariantID.put(use: updateVariant)
     withVariantID.delete(use: deleteVariant)
     }
     }
     
     withID.group("contacts") { withContact in
     withContact.post(use: addContact)
     withContact.delete(use: reomveContact)
     
     withContact.group(":contact_id") { withContactID in
     withContactID.delete(use: reomveContact)
     }
     }
     }
     
     groups.group("search") { withSearch in
     withSearch.get(use: search)
     }
     }
     
     // GET /products?show_deleted=true&page=1&per_page=10
     func all(req: Request) async throws -> PaginatedResponse<ProductResponse> {
     let reqContent = try req.query.decode(ProductRepository.Fetch.self)
     
     return try await repository.fetchAll(req: reqContent, on: req.db)
     }
     
     // POST /products
     func create(req: Request) async throws -> ProductResponse {
     let content = try validator.validateCreate(req)
     
     return try await repository.create(content: content, on: req.db)
     }
     
     // GET /products/:id
     func getByID(req: Request) async throws -> ProductResponse {
     let uuid = try validator.validateID(req)
     
     return try await repository.find(id: uuid, on: req.db)
     }
     
     // PUT /products/:id
     func update(req: Request) async throws -> ProductResponse {
     let (uuid, content) = try validator.validateUpdate(req)
     
     do {
     // check if name is duplicate
     guard let name = content.name else { throw DefaultError.invalidInput }
     
     let _ = try await repository.find(name: name, on: req.db)
     
     throw CommonError.duplicateName
     
     } catch let error as DefaultError {
     switch error {
     case .notFound: // no duplicate
     return try await repository.update(id: uuid, with: content, on: req.db)
     default:
     throw error
     }
     
     } catch let error as CommonError {
     throw error
     
     } catch {
     // Handle all other errors
     throw DefaultError.error(message: error.localizedDescription)
     }
     }
     
     // DELETE /products/:id
     func delete(req: Request) async throws -> ProductResponse {
     let uuid = try validator.validateID(req)
     
     return try await repository.delete(id: uuid, on: req.db)
     }
     
     // GET /products/search?name=xxx&page=1&per_page=10
     func search(req: Request) async throws -> PaginatedResponse<ProductResponse> {
     let _ = try validator.validateSearchQuery(req)
     let reqContent = try req.query.decode(ProductRepository.Search.self)
     
     return try await repository.search(req: reqContent, on: req.db)
     }
     
     // POST /products/:id/variants
     func createVariant(req: Request) async throws -> ProductResponse {
     let (uuid, content) = try validator.validateCreateVariant(req)
     
     return try await repository.createVariant(id: uuid, content: content, on: req.db)
     }
     
     // PUT /products/:id/variants/:variant_id
     func updateVariant(req: Request) async throws -> ProductResponse {
     let (uuid, variantId, content) = try validator.validateUpdateVariant(req)
     
     return try await repository.updateVariant(id: uuid, variantId: variantId, with: content, on: req.db)
     }
     
     // DELETE /products/:id/variants/:variant_id
     func deleteVariant(req: Request) async throws -> ProductResponse {
     let (uuid, variantId) = try validator.validateDeleteVariant(req)
     
     return try await repository.deleteVariant(id: uuid, variantId: variantId, on: req.db)
     }
     
     // POST /products/:id/contacts
     func addContact(req: Request) async throws -> ProductResponse {
     let (uuid, contactId) = try validator.validateAddContact(req)
     
     return try await repository.linkContact(id: uuid, contactId: contactId, on: req.db)
     }
     
     // DELETE /products/:id/contacts/:contact_id
     func reomveContact(req: Request) async throws -> ProductResponse {
     let (uuid, contactId) = try validator.validateRemoveContact(req)
     
     return try await repository.deleteContact(id: uuid, contactId: contactId, on: req.db)
     }
     
     }
     */
    
