//
//  File.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor

struct JWTRequest {
    
    struct GenerateToken: Content {
        let user: User
        
        init(user: User) {
            self.user = user
        }
    }
}
