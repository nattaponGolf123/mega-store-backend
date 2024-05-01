//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

extension AuthController {
    
    struct SignIn: Content, Validatable {
        let username: String
        let password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("username", as: String.self,
                            is: .count(3...))
            validations.add("password", as: String.self,
                            is: .count(3...))
        }
    }
}
