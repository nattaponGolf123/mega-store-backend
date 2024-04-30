//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

 enum InputValidateError {
     case inputValidateFailed(errors: [InputError])
 }

 extension InputValidateError: AbortError {
     var reason: String {
         switch self {
         case .inputValidateFailed:
             return "Input validate failed"
         }
     }

     var status: HTTPStatus {
         switch self {
         case .inputValidateFailed:
             return .badRequest
         }
     }
     
 }

 extension InputValidateError: InputErrorMessageProtocol {
     var code: String {
         switch self {
         case .inputValidateFailed:
             return "INPUT_VALIDATE_FAILED"
         }
     }
     
     var message: String {
         return reason
     }
     
     var errors: [InputError] {
         switch self {
         case .inputValidateFailed(let errors):
             return errors
         }
     }
     
 }

extension InputValidateError: Content {
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errors = try container.decode([InputError].self, forKey: .errors)
 
        self = .inputValidateFailed(errors: errors)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        try container.encode(errors, forKey: .errors)
    }
    
    //CodingKeys
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case errors
    }
}
