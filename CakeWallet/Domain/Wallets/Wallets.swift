//
//  WalletsService.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

final class Wallets {
    weak var account: Account?
    let keychainStorage: KeychainStorage
    let moneroWalletGateway: MoneroWalletGateway
    
    init(moneroWalletGateway: MoneroWalletGateway, account: Account?,
         keychainStorage: KeychainStorage, type: WalletType = .monero) {
        self.moneroWalletGateway = moneroWalletGateway
        self.account = account
        self.keychainStorage = keychainStorage
    }
}
