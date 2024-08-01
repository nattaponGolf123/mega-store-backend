//
//  File.swift
//  
//
//  Created by IntrodexMac on 31/7/2567 BE.
//

import Foundation


enum SortOrder: String, Codable {
    case asc
    case desc
}

extension SortOrder: Equatable {
    static func == (lhs: SortOrder, rhs: SortOrder) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
