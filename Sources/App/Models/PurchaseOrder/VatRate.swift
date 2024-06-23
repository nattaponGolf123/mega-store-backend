import Foundation
import Vapor

enum VatRate {
    case none
    case _7
    case _0

    var value: Double? {
        switch self {
        case .none:
            return nil
        case ._7:
            return 0.07
        case ._0:
            return 0.0
        }
    }
}
