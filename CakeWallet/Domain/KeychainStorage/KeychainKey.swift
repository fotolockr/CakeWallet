//
//  KeychainKey.swift
//  Wallet
//
//  Created by Cake Technologies 12/5/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

private let pinKeychainKey = "pin_password"
private let walletsPrefixKeychainKey = "wallet"

enum KeychainKey {
    case pinPassword
    case walletPassword(WalletIndex)
    case seed(WalletIndex)
    case isNew(WalletIndex)
    case isWatchOnly(WalletIndex)
    
    var patch: String {
        switch self {
        case .pinPassword:
            return formattedAuthenticateKey()
        case let .seed(index):
            return formattedWalletSeedKey(forWalletName: index.name, andType: index.type)
        case let .walletPassword(index):
            return formattedWalletPasswordKey(forWalletName: index.name, andType: index.type)
        case let .isNew(index):
            return formattedIsNewKey(forWalletName: index.name, andType: index.type)
        case let .isWatchOnly(index):
            return formattedWalletIsWatchOnlyKey(forWalletName: index.name, andType: index.type)
        }
    }
    
    private func formattedAuthenticateKey() -> String {
        return pinKeychainKey
    }
    
    private func formattedWalletPasswordKey(forWalletName walletName: String, andType type: WalletType) -> String {
        return formattedWalletKey(forWalletName: walletName, andType: type) + "_password"
    }
    
    private func formattedWalletSeedKey(forWalletName walletName: String, andType type: WalletType) -> String {
        return formattedWalletKey(forWalletName: walletName, andType: type) + "_is_watch_only"
    }
    
    private func formattedWalletIsWatchOnlyKey(forWalletName walletName: String, andType type: WalletType) -> String {
        return formattedWalletKey(forWalletName: walletName, andType: type) + "_seed"
    }
    
    private func formattedIsNewKey(forWalletName walletName: String, andType type: WalletType) -> String {
        return formattedWalletKey(forWalletName: walletName, andType: type) + "_is_new"
    }
    
    private func formattedWalletKey(forWalletName walletName: String, andType type: WalletType) -> String {
        let key = walletsPrefixKeychainKey + "_" + type.stringify().lowercased()  + "_" + walletName
        return key
    }
}
