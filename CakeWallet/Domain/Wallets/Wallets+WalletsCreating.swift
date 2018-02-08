//
//  Wallets+WalletsCreating.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

extension Wallets: WalletsCreating {
    func create(withName name: String) -> Promise<String> {
        return Promise { fulfill, reject in
            let password = self.generatePassword()
            moneroWalletGateway.create(withCredentials: WalletCreatingCredentials(name: name, password: password))
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
    
    func isExistWallet(withName name: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                fulfill(self.moneroWalletGateway.isExist(withName: name))
            }
        }
    }
    
    // MARK: generatePassword
    
    func generatePassword() -> String {
        return UUID().uuidString
    }
}
