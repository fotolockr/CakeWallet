import Foundation

public enum AuthenticationError: Error {
    case incorrectPassword
    case exceededNumberOfFailedAuthorizations
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectPassword:
            return NSLocalizedString("Incorrect Pin", comment: "")
        case .exceededNumberOfFailedAuthorizations:
            return NSLocalizedString("Exceeded number of failed authorizations", comment: "")
        }
    }
}
