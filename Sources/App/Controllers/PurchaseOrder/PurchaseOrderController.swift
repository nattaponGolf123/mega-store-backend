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
    private(set) var jwtValidator: JWTValidatorProtocol
    
    init(repository: PurchaseOrderRepositoryProtocol = PurchaseOrderRepository(),
         validator: PurchaseOrderValidatorProtocol = PurchaseOrderValidator(),
         generalValidator: GeneralValidatorProtocol = GeneralValidator(),
         jwtValidator: JWTValidatorProtocol = JWTValidator()) {
        self.repository = repository
        self.validator = validator
        self.generalValidator = generalValidator
        self.jwtValidator = jwtValidator
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
            
            withID.group("approve") { withVoid in
                withVoid.post(use: approve)
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
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
        let content = try validator.validateCreate(req)
        
        let po = try await repository.create(request: content,
                                             userId: .init(id: userPayload.userID),
                                             on: req.db)
        
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id
    func update(req: Request) async throws -> PurchaseOrderResponse {
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
        let (id, content) = try validator.validateUpdate(req)
        
        let po = try await repository.update(byId: id,
                                             request: content,
                                             userId: .init(id: userPayload.userID),
                                             on: req.db)
        
        return .init(from: po)
    }
    
    // POST /purchase_orders/:id/approve
    func approve(req: Request) async throws -> PurchaseOrderResponse {
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
        let id = try generalValidator.validateID(req)
        let po = try await repository.approve(id: id,
                                            userId: .init(id: userPayload.userID),
                                            on: req.db)
        return .init(from: po)
    }
    
    // POST /purchase_orders/:id/void
    func void(req: Request) async throws -> PurchaseOrderResponse {
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
        let id = try generalValidator.validateID(req)
        let po = try await repository.void(id: id,
                                          userId: .init(id: userPayload.userID),
                                          on: req.db)
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id/replace_items
    func replaceItems(req: Request) async throws -> PurchaseOrderResponse {
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
        let (id, content) = try validator.validateReplaceItems(req)
        
        let po = try await repository.replaceItems(id: id,
                                                 request: content,
                                                 userId: .init(id: userPayload.userID),
                                                 on: req.db)
        return .init(from: po)
    }
    
    // PUT /purchase_orders/:id/reorder_items
    func reorderItems(req: Request) async throws -> PurchaseOrderResponse {
        //let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        let userPayload = try jwtValidator.validateToken(req)
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
   
