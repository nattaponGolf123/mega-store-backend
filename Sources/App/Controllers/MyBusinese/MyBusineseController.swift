import Foundation
import Fluent
import Vapor

class MyBusineseController: RouteCollection {
    
    private(set) var repository: MyBusineseRepositoryProtocol
    private(set) var validator: MyBusineseValidatorProtocol
    
    init(repository: MyBusineseRepositoryProtocol = MyBusineseRepository(),
         validator: MyBusineseValidatorProtocol = MyBusineseValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func boot(routes: RoutesBuilder) throws {
        let busineses = routes.grouped("my_busineses")
        busineses.get(use: all)
        busineses.post(use: create)
        
        busineses.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            
            // PUT /my_busineses/:id/businese_address/:address_id
            withID.group("businese_address") { bussineseAddress in
                bussineseAddress.grouped(":address_id").put(use: updateBussineseAddress)
            }
            
            //PUT /my_busineses/:id/shipping_address/:address_id
            withID.group("shipping_address") { shippingAddress in
                shippingAddress.grouped(":address_id").put(use: updateShippingAddress)
            }
            
        }
        
    }
    
    // GET /my_busineses
    func all(req: Request) async throws -> [MyBusinese] {
        return try await repository.fetchAll(on: req.db)
    }
    
    // POST /my_busineses
    func create(req: Request) async throws -> MyBusinese {
        let content = try validator.validateCreate(req)
        return try await repository.create(request: content, on: req.db)
    }
    
     // GET /my_busineses:id
    func getByID(req: Request) async throws -> MyBusinese {
        let content = try validator.validateID(req)
        return try await repository.fetchById(request: content, on: req.db)
    }
    
    // PUT /my_busineses/:id
    func update(req: Request) async throws -> MyBusinese {
        let (id, content) = try validator.validateUpdate(req)
        return try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
    }
    
    // PUT /my_busineses/:id/businese_address/:address_id
    func updateBussineseAddress(req: Request) async throws -> MyBusinese {
        let content = try validator.validateUpdateBussineseAddress(req)
        return try await repository.updateBussineseAddress(byId: content.id,
                                                           addressID: content.addressID,
                                                           request: content.content,
                                                           on: req.db)
    }
    
    // PUT /my_busineses/:id/shipping_address/:address_id
    func updateShippingAddress(req: Request) async throws -> MyBusinese {
        let content = try validator.validateUpdateShippingAddress(req)
        return try await repository.updateShippingAddress(byId: content.id,
                                                          addressID: content.addressID,
                                                          request: content.content,
                                                          on: req.db)
    }
    
}
