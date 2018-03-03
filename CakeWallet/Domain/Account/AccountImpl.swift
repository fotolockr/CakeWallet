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
            if UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.transactionPriority.stringify()) == nil {
                return .slow
            }
            
            return TransactionPriority(rawValue: UInt64(UserDefaults.standard.integer(forKey: Configurations.DefaultsKeys.transactionPriority))) ?? .slow
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Configurations.DefaultsKeys.transactionPriority)
        }
    }
    
    var currency: Currency {
        get {
            // WARNING: Unsafe unwrap
            return Currency(rawValue: UserDefaults.standard.integer(forKey: Configurations.DefaultsKeys.currency))!
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Configurations.DefaultsKeys.currency)
            _ = forceUpdateRate()
        }
    }
    
    var connectionSettings: ConnectionSettings {
        return ConnectionSettings.loadSavedSettings()
            ?? ConnectionSettings(uri: "", login: "", password: "")
    }
    
    let keychainStorage: KeychainStorage
    private let proxyWallet: WalletProxy
    private var lastCurrencyRateUpdate: Date?
    private var currencyRate: Double {
        didSet {
            rateChangeSubscriber.forEach({ $0(currencyRate) })
        }
    }
    private var rateChangeSubscriber: [(Double) -> Void]
    
    init(keychainStorage: KeychainStorage, proxyWallet: WalletProxy) {
        self.keychainStorage = keychainStorage
        self.proxyWallet = proxyWallet
        rateChangeSubscriber = []
        currencyRate = 1
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
    
    func resetConnectionSettings() -> ConnectionSettings {
        UserDefaults.standard.set(Configurations.defaultNodeUri, forKey: Configurations.DefaultsKeys.nodeUri)
        return ConnectionSettings.loadSavedSettings() ?? ConnectionSettings(uri: Configurations.defaultNodeUri, login: "", password: "")
    }
    
    func loadCurrentWallet() -> Promise<Void> {
        guard let name = currentWalletName else {
            return Promise(error: AccountError.currentWalletIsNotSetup)
        }
        
        return wallets().loadWallet(withName: name)
    }
    
    func isAuthenticated() -> Bool {
        if let _ = proxyWallet.origin as? EmptyWallet {
            return false
        } else {
            return true
        }
    }
    
    func rate() -> Promise<Double> {
        return Promise { fulfill, reject  in
            guard currency != .usd else {
                self.currencyRate = 1
                fulfill(self.currencyRate)
                return
            }
            
            let now = Date()
            
            if lastCurrencyRateUpdate == nil {
                fetchRate(for: self.currency, base: .usd)
                    .then { currencyRate -> Void in
                        if currencyRate != 0 {
                            self.currencyRate = currencyRate
                        } else {
                            self.currencyRate = 1
                        }
                        
                        fulfill(self.currencyRate)
                        self.lastCurrencyRateUpdate = Date()
                    }.catch { error in
                        print(error)
                }
                return
            } else if
                let lastCurrencyRateUpdate = lastCurrencyRateUpdate,
                now.timeIntervalSince(lastCurrencyRateUpdate) >= 120 {
                fetchRate(for: self.currency, base: .usd)
                    .then { currencyRate -> Void in
                        if currencyRate != 0 {
                            self.currencyRate = currencyRate
                        } else {
                            self.currencyRate = 1
                        }
                        
                        fulfill(self.currencyRate)
                        self.lastCurrencyRateUpdate = Date()
                    }.catch { error in
                        print(error)
                }
            } else {
                fulfill(self.currencyRate)
            }
        }
    }
    
    func subscribeOnRateChange(_ subscriber: @escaping (Double) -> Void) {
        rateChangeSubscriber.append(subscriber)
    }
    
    private func forceUpdateRate() -> Promise<Double> {
        return Promise { fulfill, reject  in
            guard currency != .usd else {
                self.currencyRate = 1
                fulfill(self.currencyRate)
                return
            }
            
            fetchRate(for: self.currency, base: .usd)
                .then { currencyRate -> Void in
                    if currencyRate != 0 {
                        self.currencyRate = currencyRate
                    } else {
                        self.currencyRate = 1
                    }
                    
                    fulfill(self.currencyRate)
                    self.lastCurrencyRateUpdate = Date()
                }.catch { error in
                    print(error)
            }
        }
    }
}
