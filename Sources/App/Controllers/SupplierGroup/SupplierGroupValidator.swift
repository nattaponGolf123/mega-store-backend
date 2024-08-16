import Foundation
import Vapor
import Mockable

@Mockable
protocol SupplierGroupValidatorProtocol {
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> SupplierGroupRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: SupplierGroupRequest.Update)
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> Search
}

class SupplierGroupValidator: SupplierGroupValidatorProtocol {
    typealias Create = SupplierGroupRequest.Create
    typealias Update = (id: GeneralRequest.FetchById, content: SupplierGroupRequest.Update)
    typealias Search = GeneralRequest.Search
    
    func validateCreate(_ req: Request) throws -> Create {
        try Create.validate(content: req)
        
        return try req.content.decode(Create.self)
    }
    
    func validateUpdate(_ req: Request) throws -> Update {
        try SupplierGroupRequest.Update.validate(content: req)
        
        let id = try req.parameters.require("id", as: UUID.self)
        let fetchById = GeneralRequest.FetchById(id: id)
        let content = try req.content.decode(SupplierGroupRequest.Update.self)
        return (fetchById, content)
    }
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {
        return try req.query.decode(GeneralRequest.FetchById.self)
    }
    
    func validateSearchQuery(_ req: Request) throws -> Search {
        try Search.validate(content: req)
        
        let content = try req.query.decode(Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
}
