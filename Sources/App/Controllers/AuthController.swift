//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation
import Vapor
import JWT
  
class AuthController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post(use: signinJWT)
        
        auth.group("token_verify") { authVerify in
            authVerify.post(use: verifyToken)
        }
    }
    
    // POST /user/token_verify
    func verifyToken(req: Request) throws -> HTTPStatus {
        do {
            _ = try req.jwt.verify(as: UserPayload.self)
            return .ok
        } catch {
            return .unauthorized
        }
    }
    
    // POST /user
    func signinJWT(req: Request) async throws -> [String: String] {
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
        
        let payload = UserPayload(subject: "vapor-user",
                                  expiration: .init(value: .distantFuture),
                                  userID: foundUser.id,
                                  username: foundUser.username,
                                  userFullname: foundUser.fullname)
        let token = try req.jwt.sign(payload)
        
        foundUser.setToken(token,
                           expriedAt: payload.expiration.value)
        loadUsers.replace(foundUser)
        
        // save
        try LocalDatastore.shared.save(fileName: "users",
                                       data: loadUsers)
        
        return ["token": token]
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


