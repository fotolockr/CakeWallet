import Foundation

func validateWallet(name: String, maxLenght: Int = 16) throws {
    guard name.count <= maxLenght else {
        throw WalletValidationError.incorrectNameLength(maxLenght)
    }
}
