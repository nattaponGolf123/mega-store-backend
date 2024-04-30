//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

protocol ErrorMessageProtocol {
    var code: String { get }
    var message: String { get }
}

protocol InputErrorMessageProtocol {
    var code: String { get }
    var message: String { get }
    var errors: [InputError] { get }
    //var response: any Content { get }
}

struct InputError: Content {
    let message: String
    let field: String
    
    init(message: String,
         field: String) {
        self.message = message
        self.field = field
    }
    
    static func parse(failures: [ValidationResult]) -> [InputError] {
        return failures.map { failure in
            return InputError(message: failure.failureDescription ?? "",
                              field: failure.key.stringValue)
        }
    }
        
}

//struct InputErrors: Content {
//    let errors: [InputError]
//    
//    init(errors: [InputError]) {
//        self.errors = errors
//    }
//    
//    init(failures: [ValidationResult]){
//        errors = failures.map { failure in
//            return InputError(message: failure.failureDescription ?? "",
//                              field: failure.key.stringValue)
//        }
//    }
//}
