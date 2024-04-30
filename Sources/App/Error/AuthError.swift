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
        }
    }
    
    var message: String {
        return reason
    }
}
