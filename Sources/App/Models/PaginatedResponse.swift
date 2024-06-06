//
//  File.swift
//  
//
//  Created by IntrodexMac on 23/1/2567 BE.
//

import Foundation
import Vapor

struct PaginatedResponse<T: Content>: Content {
    let page: Int
    let perPage: Int
    let total: Int
    let items: [T]
    
    init(page: Int, perPage: Int, total: Int, items: [T]) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.items = items
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decode(Int.self, forKey: .page)
        perPage = try container.decode(Int.self, forKey: .perPage)
        total = try container.decode(Int.self, forKey: .total)
        items = try container.decode([T].self, forKey: .items)
    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(page, forKey: .page)
        try container.encode(perPage, forKey: .perPage)
        try container.encode(total, forKey: .total)
        try container.encode(items, forKey: .items)
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case items
    }
}
