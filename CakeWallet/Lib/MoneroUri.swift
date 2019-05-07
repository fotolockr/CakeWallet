import Foundation
import CakeWalletLib

struct MoneroUri {
    let address: String
    let paymentId: String?
    let amount: Amount?
    
    init(address: String, paymentId: String? = nil, amount: Amount? = nil) {
        self.address = address
        self.paymentId = paymentId
        self.amount = amount
    }
    
    func formatted() -> String {
        var result = "monero:\(address)"
        var paymentIDString = ""
        var amountString = ""
        
        if
            let paymentId = paymentId,
            !paymentId.isEmpty {
            paymentIDString = "tx_payment_id=\(paymentId)"
        }
        
        if let amount = amount {
            let formattedAmount = amount.formatted()
            
            if !formattedAmount.isEmpty && Double(formattedAmount) != 0 {
                amountString += "tx_amount=\(amount.formatted())"
            }
        }
        
        if !paymentIDString.isEmpty || !amountString.isEmpty {
            result += "?"
        }
        
        if !paymentIDString.isEmpty {
            result += paymentIDString
        }
        
        if !amountString.isEmpty {
            if !paymentIDString.isEmpty {
                result += "&"
            }
            
            result += amountString
        }
        
        
        return result
    }
}
