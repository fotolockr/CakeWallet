//
//  Wallets+WalletsSeedFetchable.swift
//  Wallet
//
//  Created by Cake Technologies 12/4/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation
import PromiseKit

extension Wallets: WalletsSeedFetchable {
    func fetchSeed(for walletIndex: WalletIndex) -> Promise<String> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let seed = try self.keychainStorage.fetch(forKey: .seed(walletIndex))
                    DispatchQueue.main.async {
                        fulfill(seed)
                    }
                } catch {
                    DispatchQueue.main.async {
                        reject(error)
                    }
                }
            }
        }
    }
}

protocol WalletsListFetchable {
    func fetchWalletsList() -> Promise<WalletsList>
}

extension Wallets: WalletsListFetchable {
    func fetchWalletsList() -> Promise<WalletsList> {
        return type(of: self.moneroWalletGateway).fetchWalletsList()
            .then { wallets in
                return [.monero: wallets]
        }
        
//        return Promise { fulfill, reject in
//            var list = WalletsList()
//
//            list[.monero] = ()
//
//            when(resolved: self.sources.map { source in
//                source.fetchWalletsList()
//                    .then { wallets in list[source.type] = wallets }})
//                .then { _ in observer.onNext(list) }
//                .catch { observer.onError($0) }
//        }
    }
}
