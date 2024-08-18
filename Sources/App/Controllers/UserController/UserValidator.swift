//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor
import Mockable

@Mockable
protocol UserValidatorProtocol {
    func validateCreate(_ req: Request) throws -> UserRequest.Create
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UserRequest.Update)
}

class UserValidator: UserValidatorProtocol {
        
    private var jwtRepository: JWTRepositoryProtocol
    private var jwtValidator: JWTValidatorProtocol
    
    init(jwtRepository: JWTRepositoryProtocol = JWTRepository(),
         jwtValidator: JWTValidatorProtocol = JWTValidator()) {
        self.jwtRepository = jwtRepository
        self.jwtValidator = jwtValidator
    }
 
    func validateCreate(_ req: Request) throws -> UserRequest.Create {
        let payload: UserJWTPayload = try jwtValidator.validateToken(req)
        
        // allow only admin
        guard
            payload.isAdmin
        else { throw DefaultError.unauthorized }
                
        // validate
        try UserRequest.Create.validate(content: req)
        
        let content = try req.content.decode(UserRequest.Create.self)
        return content
    }
    
    func validateUpdate(_ req: Request) throws -> (id: GeneralRequest.FetchById, content: UserRequest.Update) {
        let payload: UserJWTPayload = try jwtValidator.validateToken(req)
        
        // allow only admin
        guard
            payload.isAdmin
        else { throw DefaultError.unauthorized }
        
        let content = try req.content.decode(UserRequest.Update.self)
        guard
            let id = req.parameters.get("id", as: UUID.self)
        else { throw DefaultError.invalidInput }
        
        let fetchById = GeneralRequest.FetchById(id: id)
        return (fetchById, content)
    }
    
}
