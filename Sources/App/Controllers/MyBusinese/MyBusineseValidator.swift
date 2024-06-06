import Foundation
import Vapor

protocol MyBusineseValidatorProtocol {
    func validateCreate(_ req: Request) throws -> MyBusineseRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: MyBusineseRepository.Update)
    func validateID(_ req: Request) throws -> UUID
}

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

    func validateID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id"), let uuid = UUID(id) else { throw DefaultError.invalidInput }
        return uuid
    }
}
