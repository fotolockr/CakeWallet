import Foundation

public enum KeychainStorageError: Error {
    case cannotSetValue(String)
    case cannotFindValue(String)
    case cannotRemoveValue(String)
}

extension KeychainStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .cannotFindValue(key):
            return String(format: "Cannot find value for key: %@ in keychain", key)
        case let .cannotRemoveValue(key):
            return String(format: "Cannot remove value for key: %@ in keychain", key)
        case let .cannotSetValue(key):
            return String(format: "Cannot set value for key: %@ in keychain", key)
        }
    }
}
