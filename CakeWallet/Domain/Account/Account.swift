//
//  Account.swift
//  CakeWallet
//
//  Created by Cake Technologies 30.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol CurrencySettingsConfigurable {
    var currency: Currency { get  set }
    func subscribeOnRateChange(_ subscriber: @escaping (Double) -> Void)
    func rate() -> Promise<Double>
}

protocol AccountSettingsConfigurable {
    var isBiometricalAuthAllow: Bool { get set }
    var isPasswordRemembered: Bool { get set }
    var transactionPriority: TransactionPriority { get set }
    var connectionSettings: ConnectionSettings { get }
    var autoSwitchNode: Bool { get set }
    
    func change(connectionSettings: ConnectionSettings) -> Promise<Void>
    func resetConnectionSettings() -> ConnectionSettings
}

protocol Account: class, AccountSettingsConfigurable, CurrencySettingsConfigurable {
    var currentWallet: WalletProtocol { get }
    var currentWalletName: String? { get }
    
    func setup(newPassword password: String) -> Promise<Void>
    func change(password: String, oldPassword: String) -> Promise<Void>
    func select(wallet: WalletProtocol)
    func wallets() -> Wallets
    func walletsList() -> Promise<WalletsList>
    func loadCurrentWallet() -> Promise<Void>
    func isAuthenticated() -> Bool
}

extension Account {
    func isLogined() -> Bool {
        return currentWalletName != nil
    }
}


