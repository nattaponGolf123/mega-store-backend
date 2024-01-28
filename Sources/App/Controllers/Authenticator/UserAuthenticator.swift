//
//  File.swift
//  
//
//  Created by IntrodexMac on 25/1/2567 BE.
//

import Foundation
import Vapor
import JWT

struct UserAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization,
                      for request: Request) async throws {
        do {
            let userPayload = try request.jwt.verify(as: UserJWTPayload.self)
            // stamp user into auth list
            request.auth.login(userPayload)
        } catch {
            throw Abort(.unauthorized)
        }
   }
    
}
