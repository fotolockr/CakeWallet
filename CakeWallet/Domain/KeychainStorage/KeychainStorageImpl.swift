//
//  KeychainStorageImpl.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

final class KeychainStorageImpl: KeychainStorage {
    private let keychain: KeychainWrapper
    
    convenience init() {
        self.init(keychain: KeychainWrapper.standard)
    }
    
    init(keychain: KeychainWrapper) {
        self.keychain = keychain
    }
    
    func set(value: String, forKey key: KeychainKey) throws {
        let path = key.patch
        
        guard keychain.set(value, forKey: path) else {
            throw KeychainStorageError.cannotSetValue(path)
        }
    }
    
    func fetch(forKey key: KeychainKey) throws -> String {
        let path = key.patch
        
        guard let result = keychain.string(forKey: path) else {
            throw KeychainStorageError.cannotFindValue(path)
        }
        
        return result
    }
    
    func remove(forKey key: KeychainKey) throws {
        let path = key.patch
                
        guard keychain.removeObject(forKey: path) else {
            throw KeychainStorageError.cannotRemoveValue(path)
        }
    }
}
