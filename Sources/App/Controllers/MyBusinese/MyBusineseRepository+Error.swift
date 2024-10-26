//
//  MyBusineseRepository+Error.swift
//  poc-swift-vapor-rest
//
//  Created by IntrodexMac on 26/10/2567 BE.
//

import Vapor

extension MyBusineseRepository {
    enum Error: AbortError {
        case existingMyBusinese
        
        var reason: String {
            switch self {
            case .existingMyBusinese:
                return "Businese already exists"
            }
        }
        
        var status: HTTPStatus {
            switch self {
            case .existingMyBusinese:
                return .conflict
            }
        }
    }
}
