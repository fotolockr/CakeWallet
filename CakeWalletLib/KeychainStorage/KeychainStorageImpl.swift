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
        return try getValue(forKey: path)
    }
    
    public func remove(forKey key: KeychainKey) throws {
        let path = key.patch
        
        do {
            try keychain.remove(path)
        } catch {
            throw KeychainStorageError.cannotRemoveValue(path)
        }
    }
    
    private func getValue(forKey key: String) throws -> String {
        if
            let value = try? keychain.getString(key),
            let string = value {
            return string
        }
        
        // Case if origin string is broken string with non acsii characters. Keychain will not return value for this case, but we can filter all keys from keychain and compare with origin string for get correct key.
        
        if
            let attr = keychain.allKeys().filter({ $0 == key }).first,
            let value = try? keychain.getString(attr),
            let _value = value {
            // Resave value for origin key
            try keychain.set(_value, key: key)
            
            return _value
        }
        
        throw KeychainStorageError.cannotFindValue(key)
    }
}

