//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor

struct UserRequest {
     
    struct Create: Content, Validatable {
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
            validations.add("username", 
                            as: String.self,
                            is: .count(3...), 
                            required: true)
            validations.add("password",
                            as: String.self,
                            is: .count(6...),
                            required: true)
        }
        
    }
    
    struct Update: Content {
        let fullname: String
        
        init(fullname: String) {
            self.fullname = fullname
        }
        
    }
    
    struct UpdateToken: Content {
        let token: String
        let expiration: Date
        
        init(token: String, expiration: Date) {
            self.token = token
            self.expiration = expiration
        }
        
    }
    
    struct FetchByUsername: Content, Validatable {
        let username: String
        
        init(username: String) {
            self.username = username
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("username",
                            as: String.self,
                            is: .count(3...),
                            required: true)
        }
    }
}
