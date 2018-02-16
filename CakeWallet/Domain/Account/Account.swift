//
//  Account.swift
//  CakeWallet
//
//  Created by Cake Technologies 30.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

protocol AccountSettingsConfigurable {
    var isBiometricalAuthAllow: Bool { get set }
    var isPasswordRemembered: Bool { get set }
    var transactionPriority: TransactionPriority { get set }
    var connectionSettings: ConnectionSettings { get }
    
    func change(connectionSettings: ConnectionSettings) -> Promise<Void>
    func resetConnectionSettings() -> ConnectionSettings
}

protocol Account: class, AccountSettingsConfigurable {
    var currentWallet: WalletProtocol { get }
    var currentWalletName: String? { get }
    
    func setup(newPassword password: String) -> Promise<Void>
    func change(password: String, oldPassword: String) -> Promise<Void>
    func select(wallet: WalletProtocol)
    func wallets() -> Wallets
    func walletsList() -> Promise<WalletsList>
    func loadCurrentWallet() -> Promise<Void>
}

extension Account {
    func isLogined() -> Bool {
        return currentWalletName != nil
    }
}


