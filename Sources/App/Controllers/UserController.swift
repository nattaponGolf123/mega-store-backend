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
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        users.group("me") { usersMe in
            usersMe.get(use: me)
        }
        
    }
    
    // POST /users
    func create(req: Request) async throws -> User {
        
        let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
        
        // allow only admin
        guard
            userPayload.isAdmin
        else { throw Abort(.unauthorized) }
        
        let content = try req.content.decode(CreateUser.self)

        // validate
        try CreateUser.validate(content: req)
        
        
        let hashPwd = try getPwd(env: req.application.environment,
                             pwd: content.password)
        
        let newUser = User(username: content.username,
                           passwordHash: hashPwd,
                           fullname: content.fullname,
                           userType: .user)
        try await newUser.save(on: req.db).get()
        
        return newUser
    }
    
    // GET /users/me
    func me(req: Request) async throws -> User {
        do {
            let userPayload = try req.jwt.verify(as: UserJWTPayload.self)
            guard
                let foundUser = try await User.find(userPayload.userID,
                                                    on: req.db),
                foundUser.tokenExpried != nil
            else {
                throw Abort(.notFound)
            }
            
            return foundUser
        } catch {
            throw Abort(.notFound)
        }
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

extension UserController {
    
    struct CreateUser: Content, Validatable {
        let username: String
        let password: String
        let fullname: String
        
        init(username: String,
             password: String,
             fullname: String) {
            self.username = username
            self.password = password
            self.fullname = fullname
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String.self,
                            is: .count(3...))
            validations.add("password", as: String.self,
                            is: .count(6...))
        }
        
    }
}

/*
 struct CreateProduct: Content, Validatable {
     let name: String
     let price: Double
     let description: String
     let unit: String
     
     init(name: String,
          price: Double,
          description: String,
          unit: String) {
         self.name = name
         self.price = price
         self.description = description
         self.unit = unit
     }
     
     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         self.name = try container.decode(String.self,
                                          forKey: .name)
         self.price = try container.decode(Double.self,
                                           forKey: .price)
         self.description = (try? container.decode(String.self,
                                                 forKey: .description)) ?? ""
         self.unit = (try? container.decodeIfPresent(String.self,
                                                     forKey: .unit)) ?? "THB"
     }
     
     enum CodingKeys: String, CodingKey {
         case name = "name"
         case price = "price"
         case description = "des"
         case unit = "unit"
     }
  
     static func validations(_ validations: inout Validations) {
         validations.add("name", as: String.self,
                         is: .count(3...))
         validations.add("price", as: Double.self,
                         is: .range(0...))
         validations.add("des", as: String.self,
                         is: .count(3...),
                         required: false)
         validations.add("unit", as: String.self,
                         is: .count(3...),
                         required: false)
     }
 }
 */
