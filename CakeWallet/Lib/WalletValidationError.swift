import Foundation

enum WalletValidationError: Error {
    case incorrectNameLength(Int)
}

extension WalletValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .incorrectNameLength(maxLength):
            return "Incorrect wallet name length. Wallet name should be not more than \(maxLength) characters."
        }
    }
}
