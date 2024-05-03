import Foundation

struct ContactBank: Codable {
    let bankName: String
    let branchName: String
    let branchNumber: String
    let accountName: String
    let accountNumber: String    
    
    init(bankName: String,
         branchName: String,
         branchNumber: String,
         accountName: String,
         accountNumber: String) {
        self.bankName = bankName
        self.branchName = branchName
        self.branchNumber = branchNumber
        self.accountName = accountName
        self.accountNumber = accountNumber        
    }
}