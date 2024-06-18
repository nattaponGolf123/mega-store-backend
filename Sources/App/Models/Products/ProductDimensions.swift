//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Vapor
import Fluent

struct ProductDimension: Content {
    var length: Double
    var width: Double
    var height: Double
    var weight: Double
    var lengthUnit: String
    var widthUnit: String
    var heightUnit: String
    var weightUnit: String

    init(length: Double = 0,
         width: Double = 0,
         height: Double = 0,
         weight: Double = 0,
         lengthUnit: String = "cm",
         widthUnit: String = "cm",
         heightUnit: String = "cm",
         weightUnit: String = "kg") {
        self.length = length
        self.width = width
        self.height = height
        self.weight = weight
        self.lengthUnit = lengthUnit
        self.widthUnit = widthUnit
        self.heightUnit = heightUnit
        self.weightUnit = weightUnit
    }
//
//    //encode
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(length, forKey: .length)
//        try container.encode(width, forKey: .width)
//        try container.encode(height, forKey: .height)
//        try container.encode(weight, forKey: .weight)
//        try container.encode(lengthUnit, forKey: .lengthUnit)
//        try container.encode(widthUnit, forKey: .widthUnit)
//        try container.encode(heightUnit, forKey: .heightUnit)
//        try container.encode(weightUnit, forKey: .weightUnit)
//    }
//
//    //decode
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        length = try container.decode(Double.self, forKey: .length)
//        width = try container.decode(Double.self, forKey: .width)
//        height = try container.decode(Double.self, forKey: .height)
//        weight = try container.decode(Double.self, forKey: .weight)
//        lengthUnit = try container.decode(String.self, forKey: .lengthUnit)
//        widthUnit = try container.decode(String.self, forKey: .widthUnit)
//        heightUnit = try container.decode(String.self, forKey: .heightUnit)
//        weightUnit = try container.decode(String.self, forKey: .weightUnit)
//    }

    enum CodingKeys: String, CodingKey {
        case length
        case width
        case height
        case weight
        case lengthUnit = "length_unit"
        case widthUnit = "width_unit"
        case heightUnit = "height_unit"
        case weightUnit = "weight_unit"
    }
    
}

extension ProductDimension {
    static var lengthUnits: [String] {
        return ["cm", "m", "mm" , "inch"]
    }

    static var weightUnits: [String] {
        return ["kg", "g", "mg", "ton"]
    }
}
