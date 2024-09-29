import Foundation
import Vapor

enum TaxWithholdingRateOption: String, Codable {
    case none = "NONE"
    case _0_75 = "TAX0_75"
    case _1 = "TAX1"
    case _1_5 = "TAX1_5"
    case _2 = "TAX2"
    case _3 = "TAX3"
    case _5 = "TAX5"
    case _10 = "TAX10"
    case _15 = "TAX15"
    
    var value: Double? {
        switch self {
        case .none:
            return nil
        case ._0_75:
            return 0.0075
        case ._1:
            return 0.01
        case ._1_5:
            return 0.015
        case ._2:
            return 0.02
        case ._3:
            return 0.03
        case ._5:
            return 0.05
        case ._10:
            return 0.1
        case ._15:
            return 0.15
        }
    }
}
