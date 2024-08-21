import Foundation
import Vapor

protocol ServiceValidatorProtocol {
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> ServiceRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: ServiceRequest.Update)
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> Search
}

class ServiceValidator: ServiceValidatorProtocol {
    typealias Create = ServiceRequest.Create
    typealias Update = (id: GeneralRequest.FetchById, content: ServiceRequest.Update)
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> Create {
        try Create.validate(content: req)
        
        return try req.content.decode(Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> Update {
        try ServiceRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(ServiceRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {        
        guard
            let id = req.parameters.get("id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: id)
    }
    
    func validateSearchQuery(_ req: Request) throws -> Search {
        try Search.validate(content: req)
        
        let content = try req.query.decode(Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
}
