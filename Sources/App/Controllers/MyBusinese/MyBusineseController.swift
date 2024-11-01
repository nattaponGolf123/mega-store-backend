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
                bussineseAddress.grouped(":address_id").put(use: updateBusinessAddress)
            }
            
            //PUT /my_busineses/:id/shipping_address/:address_id
            withID.group("shipping_address") { shippingAddress in
                shippingAddress.grouped(":address_id").put(use: updateShippingAddress)
            }
            
        }
        
    }
    
    // GET /my_busineses
    func all(req: Request) async throws -> [MyBusineseResponse] {
        let all = try await repository.fetchAll(on: req.db)
        return all.map { MyBusineseResponse(from: $0) }
    }
    
    // POST /my_busineses
    func create(req: Request) async throws -> Response {
        let content = try validator.validateCreate(req)
        let myBusinese = try await repository.create(request: content, on: req.db)
        let response = MyBusineseResponse(from: myBusinese)
        
        return try Response(status: .created,
                          headers: ["Content-Type": "application/json"],
                          body: .init(data: JSONEncoder().encode(response)))
    }
    
     // GET /my_busineses:id
    func getByID(req: Request) async throws -> MyBusineseResponse {
        let content = try validator.validateID(req)
        let model = try await repository.fetchById(request: content, on: req.db)
        return .init(from: model)
    }
    
    // PUT /my_busineses/:id
    func update(req: Request) async throws -> MyBusineseResponse {
        let (id, content) = try validator.validateUpdate(req)
        let model = try await repository.update(byId: id,
                                           request: content,
                                           on: req.db)
        return .init(from: model)
    }
    
    // PUT /my_busineses/:id/businese_address/:address_id
    func updateBusinessAddress(req: Request) async throws -> MyBusineseResponse {
        let content = try validator.validateUpdateBusineseAddress(req)
        let model = try await repository.updateBusinessAddress(byId: content.id,
                                                           addressID: content.addressID,
                                                           request: content.content,
                                                           on: req.db)
        return .init(from: model)
    }
    
    // PUT /my_busineses/:id/shipping_address/:address_id
    func updateShippingAddress(req: Request) async throws -> MyBusineseResponse {
        let content = try validator.validateUpdateShippingAddress(req)
        let model = try await repository.updateShippingAddress(byId: content.id,
                                                          addressID: content.addressID,
                                                          request: content.content,
                                                          on: req.db)
        return .init(from: model)
    }
    
}
