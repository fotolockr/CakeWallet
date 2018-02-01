//
//  Wallets+WalletsLoadable.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

extension Wallets: WalletsLoadable {
    func loadWallet(withName name: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            do {
                let index = WalletIndex(name: name)
                let password = try self.keychainStorage.fetch(forKey: .walletPassword(index))
                moneroWalletGateway.load(withCredentials: WalletLoadingCredentials(name: name, password: password))
                    .then { wallet -> Void in
                        self.account?.select(wallet: wallet)
                        fulfill(())
                    }.catch { error in reject(error) }
            } catch {
                reject(error)
            }
        }
    }
}
