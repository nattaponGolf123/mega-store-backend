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
