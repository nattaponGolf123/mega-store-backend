//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

enum CommonError {
    case duplicateName
    case duplicateUsername
    case duplicateTaxNumber
}

extension CommonError: AbortError {
    
    var reason: String {
        switch self {
        case .duplicateName:
            return "Duplicate name"
        case .duplicateUsername:
            return "Duplicate username"
        case .duplicateTaxNumber:
            return "Duplicate tax number"
        }
    }
    
    var status: HTTPStatus {
        switch self {
        case .duplicateName:
            return .badRequest
        case .duplicateUsername:
            return .badRequest
        case .duplicateTaxNumber:
            return .badRequest
        }
    }
    
    //var localizedDescription
    
}

extension CommonError: ErrorMessageProtocol {
    var code: String {
        switch self {
        case .duplicateName:
            return "DUPLICATE_NAME"
        case .duplicateUsername:
            return "DUPLICATE_USERNAME"
        case .duplicateTaxNumber:
            return "DUPLICATE_TAX_NUMBER"
        }
    }
    
    var message: String {
        return reason
    }
}

extension CommonError: Content {
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(String.self, forKey: .code)
        
        switch code {
        case "DUPLICATE_NAME":
            self = .duplicateName
        case "DUPLICATE_USERNAME":
            self = .duplicateUsername
        case "DUPLICATE_TAX_NUMBER":
            self = .duplicateTaxNumber
        default:
            self = .duplicateName
        }
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .duplicateName:
            try container.encode("DUPLICATE_NAME", forKey: .code)
            try container.encode("Duplicate name", forKey: .message)
        case .duplicateUsername:
            try container.encode("DUPLICATE_USERNAME", forKey: .code)
            try container.encode("Duplicate username", forKey: .message)
        case .duplicateTaxNumber:
            try container.encode("DUPLICATE_TAX_NUMBER", forKey: .code)
            try container.encode("Duplicate tax number", forKey: .message)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
    }
}
/*
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

 */
