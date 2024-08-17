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
protocol JWTValidatorProtocol {
    func validateToken(_ content: Request,
                       now: Date) throws -> UserJWTPayload
}

class JWTValidator: JWTValidatorProtocol {
    
    func validateToken(_ content: Request,
                       now: Date = .init()) throws -> UserJWTPayload {
        let payload = try verifyPayload(content)
        
        try verifyExpried(payload.expiration.value,
                          now: now)
        
        return payload
    }
    
}

private extension JWTValidator {
    func verifyPayload(_ content: Request) throws -> UserJWTPayload {
        do {
            return try content.jwt.verify(as: UserJWTPayload.self)
        } catch {
            throw AuthError.invalidToken
        }
    }
    
    func verifyExpried(_ tokenExpried: Date,
                       now: Date) throws {
        guard
            tokenExpried >= now
        else { throw AuthError.tokenExpired }
    }
}
