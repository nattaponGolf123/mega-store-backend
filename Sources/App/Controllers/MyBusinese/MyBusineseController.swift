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
            withID.delete(use: delete)
        }
    }
    
    func all(req: Request) async throws -> [MyBusinese] {
        return try await repository.fetchAll(on: req.db)
    }
    
    func create(req: Request) async throws -> MyBusinese {
        let content = try validator.validateCreate(req)
        return try await repository.create(with: content, on: req.db)
    }
    
    func getByID(req: Request) async throws -> MyBusinese {
        let uuid = try validator.validateID(req)
        return try await repository.find(id: uuid, on: req.db)
    }
    
    func update(req: Request) async throws -> MyBusinese {
        let (uuid, content) = try validator.validateUpdate(req)
        return try await repository.update(id: uuid, with: content, on: req.db)
    }

    func delete(req: Request) async throws -> MyBusinese {
        let uuid = try validator.validateID(req)
        return try await repository.delete(id: uuid, on: req.db)
    }
}
