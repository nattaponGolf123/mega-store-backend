//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

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
