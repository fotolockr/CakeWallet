//
//  AccountImpl.swift
//  CakeWallet
//
//  Created by Cake Technologies 30.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import PromiseKit

final class AccountImpl: Account {
    var currentWallet: WalletProtocol {
        return proxyWallet
    }
    
    var currentWalletName: String? {
        // FIX-ME: Unnamed constant
        return UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentWalletName)
    }
    
    // MARK: AccountSettingsConfigurable
    
    var isBiometricalAuthAllow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
        }
    }
    
    var isPasswordRemembered: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.passwordIsRemembered)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Configurations.DefaultsKeys.passwordIsRemembered)
        }
    }
    
    var transactionPriority: TransactionPriority {
        get {
            return TransactionPriority(rawValue: UInt64(UserDefaults.standard.integer(forKey: Configurations.DefaultsKeys.transactionPriority))) ?? .default
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Configurations.DefaultsKeys.transactionPriority)
        }
    }
    
    var connectionSettings: ConnectionSettings {
        return ConnectionSettings.loadSavedSettings()
            ?? ConnectionSettings(uri: "", login: "", password: "")
    }
    
    let keychainStorage: KeychainStorage
    private let proxyWallet: WalletProxy
    
    init(keychainStorage: KeychainStorage, proxyWallet: WalletProxy) {
        self.keychainStorage = keychainStorage
        self.proxyWallet = proxyWallet
    }
    
    func walletsList() -> Promise<WalletsList> {
        return wallets().fetchWalletsList()
    }
    
    func select(wallet: WalletProtocol) {
        UserDefaults.standard.set(wallet.name, forKey: Configurations.DefaultsKeys.currentWalletName)
        UserDefaults.standard.set(WalletType.monero.rawValue, forKey: Configurations.DefaultsKeys.currentWalletType)
        proxyWallet.switch(origin: wallet)
    }
    
    func wallets() -> Wallets {
        return Wallets(moneroWalletGateway: MoneroWalletGateway(), account: self, keychainStorage: keychainStorage)
    }
    
    func setup(newPassword password: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.keychainStorage.set(value: password, forKey: .pinPassword)
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func change(password: String, oldPassword: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                guard
                    let pinPassword = try? self.keychainStorage.fetch(forKey: .pinPassword),
                    oldPassword == pinPassword  else {
                        reject(AuthenticationError.incorrectPassword)
                        return
                }
                
                do {
                    try self.keychainStorage.set(value: password, forKey: .pinPassword)
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func change(connectionSettings: ConnectionSettings) -> Promise<Void> {
        connectionSettings.save()
        return currentWallet.connect(withSettings: connectionSettings)
    }
    
    func loadCurrentWallet() -> Promise<Void> {
        guard let name = currentWalletName else {
            return Promise(error: AccountError.currentWalletIsNotSetup)
        }
        
        return wallets().loadWallet(withName: name)
    }
}
