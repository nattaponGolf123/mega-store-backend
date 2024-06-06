import Foundation
import Vapor

protocol ContactGroupValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactGroupRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactGroupRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ContactGroupValidator: ContactGroupValidatorProtocol {
    typealias CreateContent = ContactGroupRepository.Create
    typealias UpdateContent = ContactGroupRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming ContactGroup
            let content: ContactGroupValidator.CreateContent = try req.content.decode(CreateContent.self)  

            // Validate the ContactGroup directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactGroupRepository.Update) {
        typealias UpdateContactGroup = ContactGroupRepository.Update
        do {
            // Decode the incoming ContactGroup and validate it
            let content: UpdateContactGroup = try req.content.decode(UpdateContactGroup.self)
            try UpdateContactGroup.validate(content: req)
            
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
        guard let search = req.query[String.self, at: "q"] else { throw DefaultError.invalidInput }
        
        return search
    }
}

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

    func validateUpdateBussineseAddress(_ req: Request) throws -> ValidateBusineseAdressResponse {
        
        do {
            let content = try req.content.decode(MyBusineseRepository.UpdateBussineseAddress.self)
            try MyBusineseRepository.UpdateBussineseAddress.validate(content: req)
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
            let content = try req.content.decode(MyBusineseRepository.UpdateShippingAddress.self)
            try MyBusineseRepository.UpdateShippingAddress.validate(content: req)
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

extension MyBusineseValidator {
    
    struct ValidateBusineseAdressResponse {
        let id: UUID
        let addressID: UUID
        let content: MyBusineseRepository.UpdateBussineseAddress
    }

    struct ValidateShippingAddressResponse {
        let id: UUID
        let addressID: UUID
        let content: MyBusineseRepository.UpdateShippingAddress    
    }
}

*/