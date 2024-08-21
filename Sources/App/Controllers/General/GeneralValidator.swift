//
//  File.swift
//  
//
//  Created by IntrodexMac on 22/8/2567 BE.
//

import Foundation
import Vapor
import Mockable

@Mockable
protocol GeneralValidatorProtocol {
    typealias Search = GeneralRequest.Search
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById
    func validateSearchQuery(_ req: Request) throws -> Search
}

class GeneralValidator: GeneralValidatorProtocol {
    typealias Search = GeneralRequest.Search
    
    func validateID(_ req: Request) throws -> GeneralRequest.FetchById {
        guard
            let id = req.parameters.get("id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        return .init(id: id)
    }
    
    func validateSearchQuery(_ req: Request) throws -> GeneralRequest.Search {
        try Search.validate(content: req)
        
        let content = try req.query.decode(Search.self)
        
        guard content.query.isEmpty == false else { throw DefaultError.invalidInput }
        
        return content
    }
}
