import Foundation
import Vapor

protocol PurchaseOrderValidatorProtocol {
    func validateCreate(_ req: Request) throws -> PurchaseOrderRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: PurchaseOrderRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class PurchaseOrderValidator: PurchaseOrderValidatorProtocol {
    typealias CreateContent = PurchaseOrderRepository.Create
    typealias UpdateContent = PurchaseOrderRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming PurchaseOrder
            let content: PurchaseOrderValidator.CreateContent = try req.content.decode(CreateContent.self)

            // Validate the PurchaseOrder directly
            try CreateContent.validate(content: req)
            
            return content
        } catch let error as ValidationsError {
            // Parse and throw a more specific input validation error if validation fails
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            // Handle all other errors
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: UpdateContent) {
        do {
            // Decode the incoming PurchaseOrder and validate it
            let content: UpdateContent = try req.content.decode(UpdateContent.self)
            try UpdateContent.validate(content: req)
            
            // Extract the ID from the request's parameters
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

    func validateSearchQuery(_ req: Request) throws -> String {
        guard
            let search = req.query[String.self, at: "q"],
            !search.isEmpty
            else { throw DefaultError.invalidInput }
        
        return search
    }

}
