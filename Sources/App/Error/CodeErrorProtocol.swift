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
}

struct InputError {
    let message: String
    let field: String
}
