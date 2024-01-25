//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor
  
class AuthController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post(use: signin)
        
    }
    
    // POST /user
    func signin(req: Request) async throws -> User {
        // try to decode param by Auth
        let content = try req.content.decode(SignIn.self)

        // validate
        try SignIn.validate(content: req)

        // load from local
        var loadUsers = try LocalDatastore.shared.load(fileName: "users",
                                                       type: Users.self)
        
        guard 
            var foundUser = loadUsers.find(username: content.username),
            foundUser.password.lowercased() == content.password.lowercased()
        else { throw Abort(.notFound) }
        
        foundUser.generateToken()
        
        loadUsers.replace(foundUser)
        
        // save
        try LocalDatastore.shared.save(fileName: "users",
                                       data: loadUsers)

        return foundUser
    }
    
}

extension AuthController {
    
    struct SignIn: Content, Validatable {
        let username: String
        let password: String
     
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String.self,
                            is: .count(3...))
            validations.add("password", as: String.self,
                            is: .count(3...))
        }
    }
}


