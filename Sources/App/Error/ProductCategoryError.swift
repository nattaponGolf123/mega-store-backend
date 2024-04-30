//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

enum ProductCategoryError {
    case minLengthNameRequired
    case maxLengthNameExceeded
}

extension ProductCategoryError: AbortError {
    var reason: String {
        switch self {
        case .minLengthNameRequired:
            return "Name must be at least 3 characters long"
        case .maxLengthNameExceeded:
            return "Name must be less than 400 characters long"
        }
    }

    var status: HTTPStatus {
        switch self {
        case .minLengthNameRequired:
            return .badRequest
        case .maxLengthNameExceeded:
            return .badRequest
        }
    }
    
}

extension ProductCategoryError: ErrorMessageProtocol {
    var code: String {
        switch self {
        case .minLengthNameRequired:
            return "MIN_LENGTH_NAME_REQUIRED"
        case .maxLengthNameExceeded:
            return "MAX_LENGTH_NAME_EXCEEDED"
        }
    }

    var message: String {
        return reason
    }
}
