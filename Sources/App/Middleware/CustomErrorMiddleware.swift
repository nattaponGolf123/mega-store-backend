//
//  File.swift
//  
//
//  Created by IntrodexMac on 30/4/2567 BE.
//

import Foundation
import Vapor

final class ErrorHandlerMiddleware: AsyncMiddleware {
    func respond(to request: Request,
                 chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as AbortError {
            let response = Response(status: error.status)
            
            if let error = error as? ErrorMessageProtocol,
               let content = error as? (any Content) {
                try response.content.encode(content)
                return response
            }
            else if let error = error as? InputErrorMessageProtocol,
                    let content = error as? (any Content) {
                try response.content.encode(content)
                return response
            }
            
            let errorResponse = [
                "code": error.status.description,
                "message": error.reason
            ]
            try response.content.encode(errorResponse)
            return response
        } catch {
            return try Response.internalError()
        }
    }
}

extension Response {
    
    static func internalError() throws -> Response {
        let error = DefaultError.serverError
        let response = Response(status: error.status)
        try response.content.encode(DefaultError.serverError)
        return response
    }
}
