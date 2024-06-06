import Foundation

 struct ContactCode {
        @RunningCode(prefix: "C")
        var code: String 

        init(number: Int) {
            code = "\(number)"
        }
    }