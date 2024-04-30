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
            
            if let error = error as? ErrorMessageProtocol {
                let errorResponse = [
                    "code": error.code,
                    "message": error.message
                ]
                try response.content.encode(errorResponse)
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
        let response = Response(status: .internalServerError)
        let errorResponse = [
            "code": "INTERNAL_ERROR",
            "message": "Something went wrong"
        ]
        try response.content.encode(errorResponse)
        return response
    }
}
