//
//  Wallets+WalletsRecoverable.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

extension Wallets: WalletsRecoverable {
    func recoveryWallet(withName name: String, publicKey: String, viewKey: String, spendKey: String, restoreHeight: UInt64) -> Promise<String> {
        return Promise { fulfill, reject in
            guard !self.moneroWalletGateway.isExist(withName: name) else {
                reject(WalletError.walletIsExist(name))
                return
            }
            
            let password = self.generatePassword()
            let index = WalletIndex(name: name)
            
            do {
                try self.keychainStorage.set(value: password, forKey: .walletPassword(index))
                
                if spendKey.isEmpty {
                    try self.keychainStorage.set(value: String(true), forKey: .isWatchOnly(index))
                }
            } catch {
                reject(error)
            }
            
            self.moneroWalletGateway.recoveryWallet(
                withName: name,
                publicKey: publicKey,
                viewKey: viewKey,
                spendKey: spendKey,
                restoreHeight: restoreHeight,
                password: password)
                .then { wallet -> Void in
                    do {
                        try self.keychainStorage.set(value: wallet.seed, forKey: .seed(index))
                        self.account?.select(wallet: wallet)
                        fulfill(wallet.seed)
                    } catch {
                        reject(error)
                    }
                }.catch { error in reject(error) }
        }
    }
    
    func recoveryWallet(withName name: String, seed: String, restoreHeight: UInt64) -> Promise<String> {
        return Promise { fulfill, reject in
            guard !self.moneroWalletGateway.isExist(withName: name) else {
                reject(WalletError.walletIsExist(name))
                return
            }
            
            let password = self.generatePassword()
            let index = WalletIndex(name: name)
            
            do {
                try self.keychainStorage.set(value: password, forKey: .walletPassword(index))
            } catch {
                reject(error)
            }
            
            self.moneroWalletGateway.recoveryWallet(withName: name, andSeed: seed, password: password, restoreHeight: restoreHeight)
                .then { wallet -> Void in
                    do {
                        try self.keychainStorage.set(value: wallet.seed, forKey: .seed(index))
                        self.account?.select(wallet: wallet)
                        fulfill(wallet.seed)
                    } catch {
                        reject(error)
                    }
                }.catch { error in reject(error) }
        }
    }
}
