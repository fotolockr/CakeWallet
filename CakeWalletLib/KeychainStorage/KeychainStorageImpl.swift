import Foundation
import KeychainAccess

//fixme

public final class KeychainStorageImpl: KeychainStorage {
    public static let standart: KeychainStorage = KeychainStorageImpl()
    
    private static var defaultServiceName: String {
        return Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper" // legacy case
    }
    
    private let keychain: Keychain
    
    public convenience init() {
        self.init(
            keychain: Keychain(service: KeychainStorageImpl.defaultServiceName)
                .synchronizable(true)
                .accessibility(.whenUnlocked)
        )
    }
    
    public init(keychain: Keychain) {
        self.keychain = keychain
    }
    
    public func set(value: String, forKey key: KeychainKey) throws {
        let path = key.patch
        do {
            try keychain.set(value, key: path)
        } catch {
            throw KeychainStorageError.cannotSetValue(path)
        }
    }
    
    public func fetch(forKey key: KeychainKey) throws -> String {
        let path = key.patch
        
        guard
            let result = try? keychain.getString(path),
            let string = result else {
            throw KeychainStorageError.cannotFindValue(path)
        }
        
        return string
    }
    
    public func remove(forKey key: KeychainKey) throws {
        let path = key.patch
        
        do {
            try keychain.remove(path)
        } catch {
            throw KeychainStorageError.cannotRemoveValue(path)
        }
    }
}

