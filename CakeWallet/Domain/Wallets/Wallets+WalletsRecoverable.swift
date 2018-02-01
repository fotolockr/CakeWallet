//
//  Wallets+WalletsRecoverable.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

extension Wallets: WalletsRecoverable {
    func recoveryWallet(withName name: String, seed: String) -> Promise<String> {
        return Promise { fulfill, reject in
            let password = self.generatePassword()
            
            guard !self.moneroWalletGateway.isExist(withName: name) else {
                reject(WalletError.walletIsExist(name))
                return
            }
            
            self.moneroWalletGateway.recoveryWallet(withName: name, andSeed: seed, password: password)
                .then { wallet -> Void in
                    do {
                        let index = WalletIndex(name: name)
                        try self.keychainStorage.set(value: password, forKey: .walletPassword(index))
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
