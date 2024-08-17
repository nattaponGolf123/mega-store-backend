//
//  File.swift
//  
//
//  Created by IntrodexMac on 28/4/2567 BE.
//

import Foundation
import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    
    private(set) var repository: UserRepositoryProtocol
    private(set) var jwtRepository: JWTRepositoryProtocol
    
    private(set) var validator: UserValidatorProtocol
    private(set) var jwtValidator: JWTValidatorProtocol
        
    init(repository: UserRepositoryProtocol = UserRepository(),
         jwtRepository: JWTRepositoryProtocol = JWTRepository(),
         validator: UserValidatorProtocol = UserValidator(),
         jwtValidator: JWTValidatorProtocol = JWTValidator()) {
        self.repository = repository
        self.jwtRepository = jwtRepository
        self.validator = validator
        self.jwtValidator = jwtValidator
    }
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        users.group("me") { usersMe in
            usersMe.get(use: me)
        }
        
    }
    
//    func create(req: Request) async throws -> User {
//        
//        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//        
//        // allow only admin
//        guard
//            userPayload.isAdmin
//        else { throw Abort(.unauthorized) }
//                
//        // validate
//        try UserRequest.Create.validate(content: req)
//        
//        let content = try req.content.decode(UserRequest.Create.self)
//        
//        let hashPwd = try getPwd(env: req.application.environment,
//                             pwd: content.password)
//        
//        let newUser = User(username: content.username,
//                           passwordHash: hashPwd,
//                           personalInformation: .init(fullname: content.fullname),
//                           userType: .user)
//        try await newUser.save(on: req.db).get()
//        
//        return newUser
//    }
    
    // PUT /users/:id
//    func update(req: Request) async throws -> User {
//        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
//        
//        // allow only admin
//        guard
//            userPayload.isAdmin
//        else { throw Abort(.unauthorized) }
//        
//        guard let id = req.parameters.get("id", as: UUID.self) else {
//            throw Abort(.badRequest)
//        }
//        
//        let content = try req.content.decode(UserRequest.Update.self)
//        
//        // validate
//        //try UserRequest.Update.validate(content: req)
//        
//        guard let user = try await User.find(id, on: req.db).get() else {
//            throw Abort(.notFound)
//        }
//                
//        user.personalInformation.fullname = content.fullname
//        
//        try await user.update(on: req.db).get()
//        
//        return user
//    }
    
    // POST /users
    func create(req: Request) async throws -> User {
        let content = try validator.validateCreate(req)
        
        return try await repository.create(request: content,
                                           env: req.application.environment,
                                           on: req.db)
    }
    
    // PUT /users/:id
    func update(req: Request) async throws -> User {
        let content = try validator.validateUpdate(req)
        
        return try await repository.update(byId: content.id,
                                           request: content.content,
                                           on: req.db)
    }
    
    // DELETE /users/:id
    func delete(req: Request) async throws -> User {
        let id = try validator.validateID(req)
        
        return try await repository.delete(byId: id,
                                           on: req.db)
    }
    
    // GET /users/me
    func me(req: Request) async throws -> User {
        let payload: UserJWTPayload = try jwtValidator.validateToken(req,
                                                                     now: .now)
        let fetchById = GeneralRequest.FetchById(id: payload.userID)
        
        return try await repository.fetchById(request: fetchById,
                                              on: req.db)
    }
    
}

private extension UserController {
    func getPwd(env: Environment,
                pwd: String) throws -> String {
        switch env {
            // bcrypt
        case .production,
             .development:
            return try Bcrypt.hash(pwd)
            
        //plaintext on testing
        default:
            return pwd
        }
    }
}
