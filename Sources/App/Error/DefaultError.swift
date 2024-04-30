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
    case internalError
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
        case .internalError:
            return "Internal error"
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
        case .internalError:
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
        case .internalError:
            return "INTERNAL_ERROR"
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

extension DefaultError: Content {
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(String.self, forKey: .code)
        let message = try container.decode(String.self, forKey: .message)
 
        switch code {
        case "NOT_FOUND":
            self = .notFound
        case "UNAUTHORIZED":
            self = .unauthorized
        case "INVALID_INPUT":
            self = .invalidInput
        case "SERVER_ERROR":
            self = .serverError
        case "INTERNAL_ERROR":
            self = .internalError
        case "DB_CONNECTION_ERROR":
            self = .dbConnectionError
        case "INSERT_FAILED":
            self = .insertFailed
        default:
            self = .error(message: message)
        }
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notFound:
            try container.encode("NOT_FOUND", forKey: .code)
        case .unauthorized:
            try container.encode("UNAUTHORIZED", forKey: .code)
        case .invalidInput:
            try container.encode("INVALID_INPUT", forKey: .code)
        case .serverError:
            try container.encode("SERVER_ERROR", forKey: .code)
        case .internalError:
            try container.encode("INTERNAL_ERROR", forKey: .code)
        case .dbConnectionError:
            try container.encode("DB_CONNECTION_ERROR", forKey: .code)
        case .insertFailed:
            try container.encode("INSERT_FAILED", forKey: .code)
        case .error(let message):
            try container.encode("ERROR", forKey: .code)
            try container.encode(message, forKey: .message)
        }                    
    }
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
    }
}
