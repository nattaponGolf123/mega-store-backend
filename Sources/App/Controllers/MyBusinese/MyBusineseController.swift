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
       // busineses.post(use: create)
        
        busineses.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)

            withID.put("businese_address", use: updateBussineseAddress)
            withID.put("shipping_address", use: updateShippingAddress)
        }
            
    }
    
    func all(req: Request) async throws -> [MyBusinese] {
        return try await repository.fetchAll(on: req.db)
    }
    
    // func create(req: Request) async throws -> MyBusinese {
    //     let content = try validator.validateCreate(req)
    //     return try await repository.create(with: content, on: req.db)
    // }
    
    func getByID(req: Request) async throws -> MyBusinese {
        let uuid = try validator.validateID(req)
        return try await repository.find(id: uuid, on: req.db)
    }
    
    func update(req: Request) async throws -> MyBusinese {
        let (uuid, content) = try validator.validateUpdate(req)
        return try await repository.update(id: uuid, with: content, on: req.db)
    }

    func updateBussineseAddress(req: Request) async throws -> MyBusinese {
        let (uuid, content) = try validator.validateUpdateBussineseAddress(req)
        return try await repository.updateBussineseAddress(id: uuid, with: content, on: req.db)
    }

    func updateShippingAddress(req: Request) async throws -> MyBusinese {
        let (uuid, content) = try validator.validateUpdateShippingAddress(req)
        return try await repository.updateShippingAddress(id: uuid, with: content, on: req.db)
    }

    // func delete(req: Request) async throws -> MyBusinese {
    //     let uuid = try validator.validateID(req)
    //     return try await repository.delete(id: uuid, on: req.db)
    // }
}

/*
protocol MyBusineseRepositoryProtocol {
    func fetchAll(on db: Database) async throws -> [MyBusinese]
    //func create(with content: MyBusineseRepository.Create, on db: Database) async throws -> MyBusinese
    func find(id: UUID, on db: Database) async throws -> MyBusinese
    func update(id: UUID, with content: MyBusineseRepository.Update, on db: Database) async throws -> MyBusinese
    //func delete(id: UUID, on db: Database) async throws -> MyBusinese
    func updateBussineseAddress(id: UUID, with content: MyBusineseRepository.UpdateBussineseAddress, on db: Database) async throws -> MyBusinese
    func updateShippingAddress(id: UUID, with content: MyBusineseRepository.UpdateShippingAddress, on db: Database) async throws -> MyBusinese
}
*/

/*
class MyBusineseValidator: MyBusineseValidatorProtocol {
    typealias CreateContent = MyBusineseRepository.Create
    typealias UpdateContent = MyBusineseRepository.Update
    
    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            let content = try req.content.decode(CreateContent.self)
            try CreateContent.validate(content: req)
            return content
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: UpdateContent) {
        
        do {
            let content = try req.content.decode(UpdateContent.self)
            try UpdateContent.validate(content: req)
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateBussineseAddress(_ req: Request) throws -> (uuid: UUID, content: MyBusineseRepository.UpdateBussineseAddress) {
        
        do {
            let content = try req.content.decode(MyBusineseRepository.UpdateBussineseAddress.self)
            try MyBusineseRepository.UpdateBussineseAddress.validate(content: req)
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateShippingAddress(_ req: Request) throws -> (uuid: UUID, content: MyBusineseRepository.UpdateShippingAddress) {
        
        do {
            let content = try req.content.decode(MyBusineseRepository.UpdateShippingAddress.self)
            try MyBusineseRepository.UpdateShippingAddress.validate(content: req)
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id"), let uuid = UUID(id) else { throw DefaultError.invalidInput }
        return uuid
    }
}
*/
