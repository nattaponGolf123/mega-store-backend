import Foundation
import Fluent
import Vapor

class PurchaseOrderController: RouteCollection {
//    typealias CreateContent = PurchaseOrderRepository.Create
//    typealias UpdateContent = PurchaseOrderRepository.Update
//    
    private(set) var repository: PurchaseOrderRepositoryProtocol
    private(set) var validator: PurchaseOrderValidatorProtocol
    private(set) var generalValidator: GeneralValidatorProtocol
    
    init(repository: PurchaseOrderRepositoryProtocol = PurchaseOrderRepository(),
         validator: PurchaseOrderValidatorProtocol = PurchaseOrderValidator(),
         generalValidator: GeneralValidatorProtocol = GeneralValidator()) {
        self.repository = repository
        self.validator = validator
        self.generalValidator = generalValidator
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
            
//            withID.group("reject") { withVoid in
//                withVoid.post(use: reject)
//            }
            
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
    func all(req: Request) async throws -> PaginatedResponse<PurchaseOrderResponse> {
        let reqContent = try req.query.decode(PurchaseOrderRequest.FetchAll.self)
        
        let pageResponse = try await repository.fetchAll(request: reqContent,
                                                         on: req.db)
        
        let responseItems: [PurchaseOrderResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
    
    // GET /purchase_orders/:id
    func getByID(req: Request) async throws -> PurchaseOrderResponse {
        let content = try generalValidator.validateID(req)
        
        let po = try await repository.fetchById(request: content,
                                                     on: req.db)
        return .init(from: po)
    }

    // POST /purchase_orders   
    func create(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)

        let content = try validator.validateCreate(req)
        
        let po = try await repository.create(request: content,
                                             userId: .init(id: userPayload.userID),
                                             on: req.db)
        
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id
    func update(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let (id, content) = try validator.validateUpdate(req)
        
        let po = try await repository.update(byId: id,
                                             request: content,
                                             userId: .init(id: userPayload.userID),
                                             on: req.db)
        
        return .init(from: po)
    }
    
    // POST /purchase_orders/:id/approve
    func approve(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let id = try generalValidator.validateID(req)
        let po = try await repository.approve(id: id,
                                            userId: .init(id: userPayload.userID),
                                            on: req.db)
        return .init(from: po)
    }
    
    // POST /purchase_orders/:id/reject
//    func reject(req: Request) async throws -> PurchaseOrderResponse {
//        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//        let id = try generalValidator.validateID(req)
//        let po = try await repository.reject(id: id,
//                                            userId: .init(id: userPayload.userID),
//                                            on: req.db)
//        return .init(from: po)
//    }
    
    // POST /purchase_orders/:id/cancel
    func cancel(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let id = try generalValidator.validateID(req)
        let po = try await repository.cancel(id: id,
                                            userId: .init(id: userPayload.userID),
                                            on: req.db)
        return .init(from: po)
    }
    
    // POST /purchase_orders/:id/void
    func void(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let id = try generalValidator.validateID(req)
        let po = try await repository.void(id: id,
                                          userId: .init(id: userPayload.userID),
                                          on: req.db)
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id/replace_items
    func replaceItems(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let (id, content) = try validator.validateReplaceItems(req)
        
        let po = try await repository.replaceItems(id: id,
                                                 request: content,
                                                 userId: .init(id: userPayload.userID),
                                                 on: req.db)
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id/reorder_items
    func reorderItems(req: Request) async throws -> PurchaseOrderResponse {
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let (id, content) = try validator.validateReorderItems(req)
        let itemsOrderIds: [GeneralRequest.FetchById] = content.itemIdOrder.map({ .init(id: $0) })
        let po = try await repository.itemsReorder(id: id,
                                                   itemsOrder: itemsOrderIds,
                                                   userId: .init(id: userPayload.userID),
                                                   on: req.db)
        return .init(from: po)
    }
    
    // GET /purchase_orders/search?q=xxx
    func search(req: Request) async throws -> PaginatedResponse<PurchaseOrderResponse> {
        let content = try validator.validateSearchQuery(req)
        
        let pageResponse = try await repository.search(request: content,
                                                       on: req.db)
        
        let responseItems: [PurchaseOrderResponse] = pageResponse.items.map({ .init(from: $0) })
        return .init(page: pageResponse.page,
                     perPage: pageResponse.perPage,
                     total: pageResponse.total,
                     items: responseItems)
    }
    
}
    /*
     protocol PurchaseOrderRepositoryProtocol {
         func all(req: PurchaseOrderRepository.Fetch,
                  on db: Database) async throws -> PaginatedResponse<PurchaseOrderResponse>
         func create(content: PurchaseOrderRepository.Create,
                     userId: UUID,
                     on db: Database) async throws -> PurchaseOrderResponse
         func find(id: UUID,
                   on db: Database) async throws -> PurchaseOrderResponse
         func update(id: UUID,
                     with content: PurchaseOrderRepository.Update,
                     userId: UUID,
                     on db: Database) async throws -> PurchaseOrder
         func replaceItems(id: UUID,
                           with content: PurchaseOrderRepository.ReplaceItems,
                           userId: UUID,
                           on db: Database) async throws -> PurchaseOrder
         
         func approve(id: UUID,
                      userId: UUID,
                      on db: Database) async throws -> PurchaseOrder
         func reject(id: UUID,
                     userId: UUID,
                     on db: Database) async throws -> PurchaseOrder
         func cancel(id: UUID,
                     userId: UUID,
                     on db: Database) async throws -> PurchaseOrder
         func void(id: UUID,
                   userId: UUID,
                   on db: Database) async throws -> PurchaseOrder
         
         func replaceItems(id: UUID,
                           userId: UUID,
                           items: [PurchaseOrderItem], on db: Database) async throws -> PurchaseOrder
         func itemsReorder(id: UUID,
                           userId: UUID,
                           itemsOrder: [UUID], on db: Database) async throws -> PurchaseOrder
         
         func search(q: String,
                     offset: Int,
                     status: PurchaseOrderRepository.Status,
                     sortBy: PurchaseOrderRepository.SortBy,
                     sortOrder: PurchaseOrderRepository.SortOrder,
                     periodDate: PeriodDate,
                     on db: Database) async throws -> PaginatedResponse<PurchaseOrder>
         func fetchLastedNumber(year: Int,
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
    
