import Foundation
import CakeWalletLib

public enum TransactionError: Error {
    case insufficientFunds(Amount, Amount, Amount?, Amount)
    case overallBalance(Amount, Amount?)
    
    init?(from originError: NSError, amount: Amount?, balance: Amount) {
        guard originError.code == 1006 else {
            return nil
        }
        
        let isOverall = originError.description.components(separatedBy: "overall").count > 1
        let error: TransactionError
        
        if isOverall {
            error = .overallBalance(balance, amount)
        } else {
            let txAmountSplit = originError.localizedDescription.components(separatedBy: "transaction amount")
            guard txAmountSplit.count > 1 else {
                return nil
            }
            
            let totalAmountStr = txAmountSplit[1].components(separatedBy: "=").first ?? ""
            let totalAmount = MoneroAmount(from: totalAmountStr)
            let feeStr = txAmountSplit[1].components(separatedBy: "+")[1].components(separatedBy: "(fee)").first ?? ""
            let fee = MoneroAmount(from: feeStr)
            error = .insufficientFunds(balance, totalAmount, amount, fee)
        }
        
        self = error
    }
}

// MARK: TransactionError + LocalizedError

extension TransactionError: LocalizedError {
    public var errorDescription: String? {
        var error: String = NSLocalizedString("Insufficient Funds.", comment: "")
            + "\n"
        
        switch self {
        case let .insufficientFunds(balance, totalAmount, amount, fee):
            if let amount = amount {
                error += String(format: NSLocalizedString("InsufficientFundsWithAmount", comment: ""), totalAmount.formatted(), amount.formatted(), fee.formatted(), balance.formatted())
            } else {
                error += String(format: NSLocalizedString("InsufficientFunds", comment: ""), balance.formatted())
            }
        case let .overallBalance(balance, amount):
            if let amount = amount {
                error += String(format: NSLocalizedString("OverallBalanceWithAmonut", comment: ""), amount.formatted(), balance.formatted())
            } else {
                error += String(format: NSLocalizedString("OverallBalance", comment: ""), balance.formatted())
            }
        }
        
        return error
    }
}

