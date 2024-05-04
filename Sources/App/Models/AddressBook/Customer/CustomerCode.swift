 import Foundation

 struct CustomerCode {
        @RunningCode(prefix: "C")
        var code: String 

        init(number: Int) {
            code = "\(number)"
        }
    }