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
    case name
    case number
    case status
    case totalAmount = "total_amount"
    case orderDate = "order_date"
    case groupId = "group_id"
    case groupName = "group_name"
    case createdAt = "created_at"
    
    static func == (lhs: SortBy, rhs: SortBy) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
