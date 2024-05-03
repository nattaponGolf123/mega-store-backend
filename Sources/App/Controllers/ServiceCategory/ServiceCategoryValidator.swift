//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

protocol ServiceCategoryValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ServiceCategory.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID,content: ServiceCategory.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> String
}

class ServiceCategoryValidator: ServiceCategoryValidatorProtocol {
    
    func validateCreate(_ req: Request) throws -> ServiceCategory.Create {
        typealias CreateContent = ServiceCategory.Create
        do {
            // Decode the incoming content
            let content = try req.content.decode(CreateContent.self)

            // Validate the content directly
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

    func validateUpdate(_ req: Request) throws -> (uuid: UUID,content: ServiceCategory.Update) {
        typealias UpdateContent = ServiceCategory.Update
        do {
            // Decode the incoming content and validate it
            let content = try req.content.decode(UpdateContent.self)
            try UpdateContent.validate(content: req)
            
            // Extract the ID from the request's parameters
            guard 
                let id = req.parameters.get("id",
                                            as: UUID.self)
            else { throw DefaultError.invalidInput }
            
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard
            let id = req.parameters.get("id"),
            let uuid = UUID(id)
        else { throw DefaultError.invalidInput }
        
        return uuid
    }

    func validateSearchQuery(_ req: Request) throws -> String {
        guard
            let search = req.query[String.self,
                                   at: "q"]
        else { throw DefaultError.invalidInput }
        
        return search
    }
}
