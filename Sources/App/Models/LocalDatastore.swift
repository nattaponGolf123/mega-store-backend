//
//  File.swift
//
//
//  Created by IntrodexMac on 24/1/2567 BE.
//

import Foundation

class LocalDatastore {
    static let shared: LocalDatastore = .init()
    
    init() {
        print("LocalDatastore init")
    }
    
    //save struct codable with .json file format on disk
    func save(fileName: String,
              data: Codable) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(data)
        let url = URL(fileURLWithPath: "\(fileName).json")
        try data.write(to: url)
    }
    
    //load strcut codable from .json file format on disk and cast to Codable
    func load<T: Codable>(fileName: String,
                          type: T.Type) throws -> T {
        let url = URL(fileURLWithPath: "\(fileName).json")
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let result = try decoder.decode(type, from: data)
        return result
    }
}
