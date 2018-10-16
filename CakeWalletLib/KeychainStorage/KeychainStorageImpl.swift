import Foundation
import SwiftKeychainWrapper

//fixme

public final class KeychainStorageImpl: KeychainStorage {
    public static let standart: KeychainStorage = KeychainStorageImpl()
    
    private let keychain: KeychainWrapper
    
    public convenience init() {
        self.init(keychain: KeychainWrapper.standard)
    }
    
    public init(keychain: KeychainWrapper) {
        self.keychain = keychain
    }
    
    public func set(value: String, forKey key: KeychainKey) throws {
        let path = key.patch
        
        guard keychain.set(value, forKey: path) else {
            throw KeychainStorageError.cannotSetValue(path)
        }
    }
    
    public func fetch(forKey key: KeychainKey) throws -> String {
        let path = key.patch
        
        guard let result = keychain.string(forKey: path) else {
            throw KeychainStorageError.cannotFindValue(path)
        }
        
        return result
    }
    
    public func remove(forKey key: KeychainKey) throws {
        let path = key.patch
        
        guard keychain.removeObject(forKey: path) else {
            throw KeychainStorageError.cannotRemoveValue(path)
        }
    }
}

