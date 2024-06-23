import Foundation
import Vapor

enum TaxWithholdingRate {
    case none
    case _0_75
    case _1
    case _1_5
    case _2
    case _3
    case _5
    case _10
    case _15
    
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
