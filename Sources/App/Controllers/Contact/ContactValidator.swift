import Foundation
import Vapor

protocol ContactValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactRepository.Update)
    func validateUpdateBussineseAddress(_ req: Request) throws -> ContactValidator.ValidateBusineseAdressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> ContactValidator.ValidateShippingAddressResponse
    func validateID(_ req: Request) throws -> UUID
}

class ContactValidator: ContactValidatorProtocol {
    typealias CreateContent = ContactRepository.Create
    typealias UpdateContent = ContactRepository.Update
    
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

    func validateUpdateBussineseAddress(_ req: Request) throws -> ValidateBusineseAdressResponse {
        
        do {
            let content = try req.content.decode(ContactRepository.UpdateBussineseAddress.self)
            try ContactRepository.UpdateBussineseAddress.validate(content: req)
            guard 
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
                else { throw DefaultError.invalidInput }

            return .init(id: id,
                         addressID: addressID,
                        content: content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateShippingAddress(_ req: Request) throws -> ValidateShippingAddressResponse {
        
        do {
            let content = try req.content.decode(ContactRepository.UpdateShippingAddress.self)
            try ContactRepository.UpdateShippingAddress.validate(content: req)
            guard 
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
             else { throw DefaultError.invalidInput }

            return .init(id: id,
                         addressID: addressID,
                         content: content)
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

extension ContactValidator {
    
    struct ValidateBusineseAdressResponse {
        let id: UUID
        let addressID: UUID
        let content: ContactRepository.UpdateBussineseAddress
    }

    struct ValidateShippingAddressResponse {
        let id: UUID
        let addressID: UUID
        let content: ContactRepository.UpdateShippingAddress    
    }
}
