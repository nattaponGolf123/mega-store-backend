//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

enum DefaultError {
    case notFound
    case unauthorized
    case invalidInput
    case serverError
}

extension DefaultError: AbortError {
    var reason: String {
        switch self {
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Unauthorized"
        case .invalidInput:
            return "Invalid input"
        case .serverError:
            return "Server error"
        }
        
    }

    var status: HTTPStatus {
        switch self {
        case .notFound:
            return .notFound
        case .unauthorized:
            return .unauthorized
        case .invalidInput:
            return .badRequest
        case .serverError:
            return .internalServerError
        }
    }
    
}

extension DefaultError: ErrorMessageProtocol {
    var code: String {
        switch self {
        case .notFound:
            return "NOT_FOUND"
        case .unauthorized:
            return "UNAUTHORIZED"
        case .invalidInput:
            return "INVALID_INPUT"
        case .serverError:
            return "SERVER_ERROR"
        }
    }
    
    var message: String {
        return reason
    }
}
