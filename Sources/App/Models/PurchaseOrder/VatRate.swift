import Foundation
import Vapor

enum VatRateOption: String, Codable {
    case none = "NONE"
    case _7 = "VAT7"
    case _0 = "VAT0"

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
