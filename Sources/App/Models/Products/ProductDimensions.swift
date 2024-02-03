//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

struct ProductDimensions: Codable, Content {
    var length: Double
    var width: Double
    var height: Double
    var weight: Double
    var lengthUnit: String
    var weightUnit: String

    init(length: Double, 
         width: Double,
         height: Double,
         weight: Double,
         lengthUnit: String,
         weightUnit: String) {
        self.length = length
        self.width = width
        self.height = height
        self.weight = weight
        self.lengthUnit = lengthUnit
        self.weightUnit = weightUnit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        length = try container.decode(Double.self, forKey: .length)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        lengthUnit = try container.decode(String.self, forKey: .lengthUnit)
        weightUnit = try container.decode(String.self, forKey: .weightUnit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(length, forKey: .length)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(weight, forKey: .weight)
        try container.encode(lengthUnit, forKey: .lengthUnit)
        try container.encode(weightUnit, forKey: .weightUnit)
    }
    
    enum CodingKeys: String, CodingKey {
        case length
        case width
        case height
        case weight
        case lengthUnit = "length_unit"
        case weightUnit = "weight_unit"
    }
}
