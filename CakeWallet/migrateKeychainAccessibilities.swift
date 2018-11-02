import Foundation
import CWMonero
import CakeWalletLib
import CakeWalletCore

private  let migratedKeychainAccessibilitiesKey = "migratedKeychainAccessibilities"

func migrateKeychainAccessibilities(keychain: KeychainStorage) throws {
    let isMigrated = UserDefaults.standard.bool(forKey: migratedKeychainAccessibilitiesKey)
    
    guard !isMigrated else {
        return
    }
    
    if let pinCode = try? keychain.fetch(forKey: .pinCode) {
        let key = KeychainKey.pinCode
        try keychain.remove(forKey: key)
        try keychain.set(value: pinCode, forKey: .pinCode)
    }
    
    let wallets = MoneroWalletGateway.fetchWalletsList()
    try wallets.forEach { index in
        if let walletPassword = try? keychain.fetch(forKey: .walletPassword(index)) {
            let key = KeychainKey.walletPassword(index)
            try keychain.remove(forKey: key)
            try keychain.set(value: walletPassword, forKey: key)
        }
        
        if let isNew = try? keychain.fetch(forKey: .isNew(index)) {
            let key = KeychainKey.isNew(index)
            try keychain.remove(forKey: key)
            try keychain.set(value: isNew, forKey: key)
        }
        
        if let seed = try? keychain.fetch(forKey: .seed(index)) {
            let key = KeychainKey.seed(index)
            try keychain.remove(forKey: key)
            try keychain.set(value: seed, forKey: key)
        }
        
        if let isWatchOnly = try? keychain.fetch(forKey: .isWatchOnly(index)) {
            let key = KeychainKey.isWatchOnly(index)
            try keychain.remove(forKey: key)
            try keychain.set(value: isWatchOnly, forKey: key)
        }
    }
    
    UserDefaults.standard.set(true, forKey: migratedKeychainAccessibilitiesKey)
}
