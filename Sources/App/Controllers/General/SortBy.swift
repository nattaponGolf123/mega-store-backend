//
//  File.swift
//  
//
//  Created by IntrodexMac on 31/7/2567 BE.
//

import Foundation
import Mockable

protocol Sortable: Codable, Equatable {
    var rawValue: String { get }
}

extension Sortable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    func areEqual(rhs: Self) -> Bool {
        return self.rawValue == rhs.rawValue
    }
}

enum SortBy: String, Sortable {
    case name = "NAME"
    case number = "NUMBER"
    case status = "STATUS"
    case totalAmount = "TOTAL_AMOUNT"
    case orderDate = "ORDER_DATE"
    case groupId = "GROUP_ID"
    case groupName = "GROUP_NAME"
    case createdAt = "CREATED_AT"
    
    static func == (lhs: SortBy, rhs: SortBy) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
