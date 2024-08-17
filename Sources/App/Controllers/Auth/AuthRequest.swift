//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor

struct AuthRequest {
    
    struct SignIn: Content, Validatable {
        let username: String
        let password: String
        
        init(username: String, 
             password: String) {
            self.username = username
            self.password = password
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("username",
                            as: String.self,
                            is: .count(3...),
                            required: true)
            validations.add("password",
                            as: String.self,
                            is: .count(3...),
                            required: true)
        }
    }
    
    struct GenerateToken: Content {
        let payload: UserJWTPayload
        let token: String
    }
    
}
