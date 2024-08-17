//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

enum AuthError {
    case invalidUsernameOrPassword
    case userAlreadyExists
    case invalidToken
    case invalidRefreshToken
    case userNotFound
    case userNotAuthorized
    case tokenExpired
    case error(message: String)
}

extension AuthError: AbortError {
    var reason: String {
        switch self {
        case .invalidUsernameOrPassword:
            return "Invalid username or password"
        case .userAlreadyExists:
            return "User already exists"
        case .invalidToken:
            return "Invalid token"
        case .invalidRefreshToken:
            return "Invalid refresh token"
        case .userNotFound:
            return "User not found"
        case .userNotAuthorized:
            return "User not authorized"
        case .tokenExpired:
            return "Token expired"
        case .error(let message):
            return message
        }
    }

    var status: HTTPStatus {
        switch self {
        case .invalidUsernameOrPassword:
            return .badRequest
        case .userAlreadyExists:
            return .badRequest
        case .invalidToken:
            return .unauthorized
        case .invalidRefreshToken:
            return .unauthorized
        case .userNotFound:
            return .notFound
        case .userNotAuthorized:
            return .unauthorized
        case .tokenExpired:
            return .unauthorized
        case .error:
            return .badRequest
        }
    }
    
}

extension AuthError: ErrorMessageProtocol {
    var code: String {
        switch self {
        case .invalidUsernameOrPassword:
            return "INVALID_USERNAME_OR_PASSWORD"
        case .userAlreadyExists:
            return "USER_ALREADY_EXISTS"
        case .invalidToken:
            return "INVALID_TOKEN"
        case .invalidRefreshToken:
            return "INVALID_REFRESH_TOKEN"
        case .userNotFound:
            return "USER_NOT_FOUND"
        case .userNotAuthorized:
            return "USER_NOT_AUTHORIZED"
        case .tokenExpired:
            return "TOKEN_EXPIRED"
        case .error:
            return "ERROR"
        }
    }
    
    var message: String {
        return reason
    }
}

extension AuthError: Content {
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(String.self, forKey: .code)
        let message = try container.decode(String.self, forKey: .message)

        switch code {
        case "INVALID_USERNAME_OR_PASSWORD":
            self = .invalidUsernameOrPassword
        case "USER_ALREADY_EXISTS":
            self = .userAlreadyExists
        case "INVALID_TOKEN":
            self = .invalidToken
        case "INVALID_REFRESH_TOKEN":
            self = .invalidRefreshToken
        case "USER_NOT_FOUND":
            self = .userNotFound
        case "USER_NOT_AUTHORIZED":
            self = .userNotAuthorized
        default:
            self = .error(message: message)
        }
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .invalidUsernameOrPassword:
            try container.encode("INVALID_USERNAME_OR_PASSWORD", forKey: .code)
        case .userAlreadyExists:
            try container.encode("USER_ALREADY_EXISTS", forKey: .code)
        case .invalidToken:
            try container.encode("INVALID_TOKEN", forKey: .code)
        case .invalidRefreshToken:
            try container.encode("INVALID_REFRESH_TOKEN", forKey: .code)
        case .userNotFound:
            try container.encode("USER_NOT_FOUND", forKey: .code)
        case .userNotAuthorized:
            try container.encode("USER_NOT_AUTHORIZED", forKey: .code)
        case .tokenExpired:
            try container.encode("TOKEN_EXPIRED", forKey: .code)
        case .error:
            try container.encode("ERROR", forKey: .code)
        }
        
        try container.encode(message, forKey: .message)
    }
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
    }
}

extension AuthError: Equatable {
    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUsernameOrPassword, .invalidUsernameOrPassword):
            return true
        case (.userAlreadyExists, .userAlreadyExists):
            return true
        case (.invalidToken, .invalidToken):
            return true
        case (.invalidRefreshToken, .invalidRefreshToken):
            return true
        case (.userNotFound, .userNotFound):
            return true
        case (.userNotAuthorized, .userNotAuthorized):
            return true
        case (.tokenExpired, .tokenExpired):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
