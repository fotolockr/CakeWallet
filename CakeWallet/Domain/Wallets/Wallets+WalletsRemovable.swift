//
//  Wallets+WalletsRemovable.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

extension Wallets: WalletsRemovable {
    func removeWallet(withIndex index: WalletIndex) -> Promise<Void> {
        return Promise { fulfill, reject in
            do {
                let password = try self.keychainStorage.fetch(forKey: .walletPassword(index))
                self.moneroWalletGateway.remove(withName: index.name, password: password)
                    .then { _ -> Void in
                        try self.keychainStorage.remove(forKey: .walletPassword(index))
                        try self.keychainStorage.remove(forKey: .seed(index))
                        fulfill(())
                    }.catch { error in reject(error) }
            } catch {
                reject(error)
            }
        }
    }
}
