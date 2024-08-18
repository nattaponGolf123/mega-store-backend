//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor
import Mockable
import JWTKit

@Mockable
protocol JWTValidatorProtocol {
    func validateToken(_ content: Request) throws -> UserJWTPayload
}

class JWTValidator: JWTValidatorProtocol {
    
    func validateToken(_ content: Request) throws -> UserJWTPayload {
        return try verifyPayload(content)
    }
    
}

private extension JWTValidator {
    func verifyPayload(_ content: Request) throws -> UserJWTPayload {
        do {
            return try content.jwt.verify(as: UserJWTPayload.self)
        } catch let error as JWTError {
            switch error {
            case .claimVerificationFailure(_ ,let reason):
                if reason == "expired" {
                    throw AuthError.tokenExpired
                }
                throw AuthError.invalidToken
            default:
                throw AuthError.invalidToken
            }
        } catch {
            throw AuthError.invalidToken
        }
    }
    
}
