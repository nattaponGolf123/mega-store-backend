//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver
import Mockable

@Mockable
protocol UserRepositoryProtocol {
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User
    
    func fetchByUsername(
        request: UserRequest.FetchByUsername,
        on db: Database
    ) async throws -> User
    
    func create(
        request: UserRequest.Create,
        env: Environment,
        on db: Database
    ) async throws -> User
    
    func update(
        byId: GeneralRequest.FetchById,
        request: UserRequest.Update,
        on db: Database
    ) async throws -> User
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User
    
    func clearToken(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User
    
    func updateToken(
        byId: GeneralRequest.FetchById,
        request: UserRequest.UpdateToken,
        on db: Database
    ) async throws -> User
    
    func verifyExistToken(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws
       
}

class UserRepository: UserRepositoryProtocol {
       
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User {
        guard
            let found = try await User.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func fetchByUsername(
        request: UserRequest.FetchByUsername,
        on db: Database
    ) async throws -> User {
        guard
            let found = try await User.query(on: db).filter(\.$username == request.username).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
  
    func create(
        request: UserRequest.Create,
        env: Environment = .development,
        on db: Database
    ) async throws -> User {
        // prevent duplicate username
        if let _ = try? await fetchByUsername(request: .init(username: request.username),
                                              on: db) {
            throw CommonError.duplicateUsername
        }
        
        let hashPwd = try getPwd(env: env,
                                 pwd: request.password)
        
        let user = User(username: request.username,
                        passwordHash: hashPwd,
                        personalInformation: .init(fullname: request.fullname),
                        userType: .user)
        
        try await user.save(on: db)
        return user
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: UserRequest.Update,
        on db: Database
    ) async throws -> User {
        let user = try await fetchById(request: .init(id: byId.id), on: db)
        
        user.personalInformation.fullname = request.fullname
        
        try await user.save(on: db)
        return user
    }
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User {
        let user = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        try await user.delete(on: db)
        return user
    }
    
    func clearToken(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> User {
        let user = try await fetchById(request: .init(id: byId.id), on: db)
        
        user.clearToken()
        
        try await user.save(on: db)
        return user
    }
    
    func updateToken(
        byId: GeneralRequest.FetchById,
        request: UserRequest.UpdateToken,
        on db: Database
    ) async throws -> User {
        let user = try await fetchById(request: .init(id: byId.id), on: db)
        
        user.setToken(request.token,
                      expried: request.expiration)
        
        try await user.save(on: db)
        return user
    }
    
    func verifyExistToken(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws {
        let user = try await fetchById(request: .init(id: byId.id), on: db)
        
        guard
            let _ = user.token,
            let _ = user.tokenExpried
        else { throw AuthError.invalidToken }
    }
    
}

private extension UserRepository {
    func getPwd(env: Environment,
                pwd: String) throws -> String {
        switch env {
        case .production,
             .development:
            // bcrypt
            return try Bcrypt.hash(pwd)
            
        //plaintext on testing
        default:
            return pwd
        }
    }
}
