//
//  File.swift
//
//
//  Created by IntrodexMac on 23/1/2567 BE.
//

import Foundation
import Vapor

struct Products: Codable {
    var lists: [Product]
    
    init(lists: [Product]) {
        self.lists = lists
    }

    init(from decoder: Decoder) throws {
        var lists = [Product]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let product = try container.decode(Product.self)
            lists.append(product)
        }
        self.lists = lists
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for product in lists {
            try container.encode(product)
        }
    }
    
    func filter(withName: String) -> Products {
        let q = withName.lowercased()
        let result = lists.filter { $0.name.lowercased().contains(q) }
        return Products(lists: result)
    }
    
    func latedID() -> Int {
        let result = lists.sorted { $0.id > $1.id }
        return (result.first?.id ?? 0) + 1
    }
    
    func find(id: Int) -> Product? {
        return lists.first { $0.id == id }
    }
    
    mutating func append(_ product: Product) {
        lists.append(product)
    }
    
    mutating func replace(_ product: Product) {
        guard 
            let index = lists.firstIndex(where: { $0.id == product.id })
        else { return }
        
        lists[index] = product
    }
        
    mutating func delete(id: Int) {
        guard 
            let index = lists.firstIndex(where: { $0.id == id })
        else { return }
        
        lists.remove(at: index)
    }
}

extension Products: AsyncResponseEncodable {
    func encodeResponse(for request: Request) async throws -> Response {
        let response = Response()
        try response.content.encode(self,
                                    as: .json)
        return response
    }
}

extension Products: Content {}

extension Products {
    struct Stub {
        static var applDevices: Products {
            return Products(lists: [
                Product.Stub.ip7,
                Product.Stub.ip7p,
                Product.Stub.ip8,
                Product.Stub.ip8p,
                Product.Stub.ipx,
                Product.Stub.ipxs,
                Product.Stub.ipxsmax,
                Product.Stub.ipxr,
                Product.Stub.ip11,
                Product.Stub.ip11p
            ])
        }
    }
}
