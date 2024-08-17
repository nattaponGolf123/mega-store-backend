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
protocol JWTRepositoryProtocol {
    func generateToken(request: JWTRequest.GenerateToken,
                       req: Request) throws -> (token: String, payload: UserJWTPayload)
}

class JWTRepository: JWTRepositoryProtocol {
    
    func generateToken(request: JWTRequest.GenerateToken,
                       req: Request) throws -> (token: String, payload: UserJWTPayload) {
        let payload = UserJWTPayload(user: request.user)
        let token = try req.jwt.sign(payload)
        return (token, payload)
    }
    
}
