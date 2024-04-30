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
    case dbConnectionError
    case insertFailed
    case error(message: String)
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
        case .dbConnectionError:
            return "Database connection error"
        case .insertFailed:
            return "Insert failed"
        case .error(let message):
            return message
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
        case .dbConnectionError:
            return .internalServerError
        case .insertFailed:
            return .badRequest
        case .error:
            return .badRequest
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
        case .dbConnectionError:
            return "DB_CONNECTION_ERROR"
        case .insertFailed:
            return "INSERT_FAILED"
        case .error:
            return "ERROR"            
        }
    }
    
    var message: String {
        return reason
    }
}
