//
//  File.swift
//  
//
//  Created by IntrodexMac on 25/1/2567 BE.
//

import Foundation
import Vapor

struct UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization,
                      for request: Request) async throws {
        
        //load user list from disk
        let loadUsers = try LocalDatastore.shared.load(fileName: "users",
                                                       type: Users.self)
        let token = bearer.token
        guard
            let foundUser = loadUsers.find(token: token)
        else { throw Abort(.unauthorized) }
        
        //check expried
        if let expriedDate = foundUser.tokenExpried {
            let now = Date()
            
            // token expried
            if expriedDate < now {
                throw Abort(.unauthorized)
            }
        }
        
        // stamp user into auth list
        request.auth.login(foundUser)
   }
    
}
