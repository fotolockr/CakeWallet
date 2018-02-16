//
//  DependencyContainer.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import Dip
import SwiftKeychainWrapper

let container = DependencyContainer.configure()

extension DependencyContainer {
    static func configure() -> DependencyContainer {
        return DependencyContainer { container in
            // MARK: KeychainStorage
            
            container.register(.singleton) {
                KeychainStorageImpl(keychain: KeychainWrapper.standard) as KeychainStorage
            }
            
            // MARK: WalletProxy
            
            container.register(.singleton) {
                WalletProxy(origin: EmptyWallet())
                }.implements(WalletProxy.self)
            
            // MARK: AuthenticationProtocol, Account, AccountSettingsConfigurable
            
            container.register(.singleton) {
                AccountImpl(keychainStorage: try! container.resolve(), proxyWallet: try! container.resolve() as WalletProxy)
                }.implements(AuthenticationProtocol.self, Account.self, AccountSettingsConfigurable.self)
            
            // MARK: Wallets
            
            container.register { moneroWalletGateway, account, keychainStorage in
                Wallets(moneroWalletGateway: moneroWalletGateway, account: account, keychainStorage: keychainStorage)
                }.implements(
                    WalletsCreating.self,
                    WalletsRecoverable.self,
                    WalletsLoadable.self,
                    WalletsRemovable.self)
                .implements(EstimatedFeeCalculable.self)
            
            // MARK: RateTicker
            
            container.register(.singleton) { MoneroRateTicker() }
                .implements(RateTicker.self)
            
            // MARK: WelcomeViewController
            
            container.register { WelcomeViewController() }
            
            // MARK: PinPasswordViewController
            
            container.register { canClose in PinPasswordViewController(canClose: canClose) }
            
            // MARK: SetupPinPasswordViewController
            
            container.register {
                SetupPinPasswordViewController(
                    account: try! container.resolve() as AccountImpl,
                    pinPasswordViewController: try! container.resolve(arguments: false) as PinPasswordViewController)
            }
            
            
            // MARK: AddWalletViewController
            
            container.register { AddWalletViewController() }
            
            // MARK: NewWalletViewController
            
            container.register { (wallets: Wallets) in  NewWalletViewController(wallets: wallets as WalletsCreating) }
            
            // MARK: RecoveryViewController
            
            container.register { (wallets: Wallets) in  RecoveryViewController(wallets: wallets as WalletsRecoverable) }
            
            // MARK: SeedViewController
            
            container.register { SeedViewController(wallet: try! container.resolve() as WalletProxy) }
            container.register { (wallet: WalletProtocol) in SeedViewController(wallet: wallet) }
            container.register { (seed: String, name: String) in SeedViewController(seed: seed, name: name) }
            
            // MARK: SummaryViewController
            
            container.register { (wallet: WalletProtocol) in
                DashboardViewController(wallet: wallet, rateTicker: try! container.resolve() as RateTicker)
            }
            
            // MARK: ReceiveViewController
            
            container.register { (wallet: WalletProtocol) in ReceiveViewController(wallet: wallet) }
            
            // MARK: SendViewController
            
            container.register {
                SendViewController(
                    accountSettings: try! container.resolve() as AccountSettingsConfigurable,
                    estimatedFeeCalculation: (try! container.resolve() as Account).wallets(),
                    transactionCreation:  (try! container.resolve() as Account).currentWallet,
                    rateTicker: try! container.resolve() as RateTicker)
            }
            
            // MARK: UnlockViewController
            
            container.register { (account: Account & AuthenticationProtocol) in
                LoginViewController(account: account)
            }
            
            // MARK: WalletKeyViewController
            
            container.register { WalletKeyViewController(wallet: try! container.resolve() as WalletProxy) }
            container.register { (wallet: WalletProtocol) in WalletKeyViewController(wallet: wallet) }
            container.register { (wallet) in WalletKeyViewController(wallet: wallet) }
            container.register { (name: String, viewKey: WalletKey, spendKey: WalletKey) in WalletKeyViewController(name: name, viewKey: viewKey, spendKey: spendKey) }
            
            // MARK: SettingsViewController
            
            container.register {
                SettingsViewController(
                    accountSettings: try! container.resolve() as AccountSettingsConfigurable,
                    showSeedIsAllow: !(try! container.resolve() as WalletProxy).isWatchOnly)
                }.resolvingProperties { (container: DependencyContainer, vc: SettingsViewController) in
                    vc.presentWalletsScreen = { [weak vc] in
                        let walletsListViewController = try! container.resolve() as WalletsViewController
                        vc?.navigationController?.pushViewController(walletsListViewController, animated: true)
                    }
                    
                    vc.presentChangePasswordScreen = { [weak vc] in
                        let changePasswordViewController = try! container.resolve() as ChangePasswordViewController
                        changePasswordViewController.onPasswordChanged = { [weak changePasswordViewController] in
                            changePasswordViewController?.dismiss(animated: true)
                        }
                        vc?.present(changePasswordViewController, animated: true)
                    }
                    
                    vc.presentNodeSettingsScreen = { [weak vc] in
                        let nodeSettingsViewController = try! container.resolve() as NodeSettingsViewController
                        vc?.navigationController?.pushViewController(nodeSettingsViewController, animated: true)
                    }
                    
                    vc.presentWalletKeys = { [weak vc] in
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        verifyPinPasswordViewController.onVerified = {
                            let walletKeyViewController = try! container.resolve() as WalletKeyViewController
                            let navController = UINavigationController(rootViewController: walletKeyViewController)
                            verifyPinPasswordViewController.dismiss(animated: false) {
                                vc?.present(navController, animated: true)
                            }
                        }
                        
                        vc?.present(verifyPinPasswordViewController, animated: true)
                    }
                    
                    vc.presentWalletSeed = {
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        
                        if verifyPinPasswordViewController.canBePresented {
                            let navController = UINavigationController(rootViewController: verifyPinPasswordViewController)
                            verifyPinPasswordViewController.onVerified = {
                                let seedViewController = try! container.resolve() as SeedViewController
                                seedViewController.finishHandler = { [weak seedViewController] in
                                    seedViewController?.dismiss(animated: true) {
                                        navController.viewControllers = []
                                    }
                                }
                                
                                navController.setNavigationBarHidden(false, animated: false)
                                navController.pushViewController(seedViewController, animated: true)
                            }
                            
                            vc.present(navController, animated: true)
                        } else {
                            let seedViewController = try! container.resolve() as SeedViewController
                            let navController = UINavigationController(rootViewController: seedViewController)
                            seedViewController.finishHandler = { [weak seedViewController] in
                                seedViewController?.dismiss(animated: true) {
                                    navController.viewControllers = []
                                }
                            }
                            
                            vc.present(navController, animated: true)
                        }
                    }
                }
            
            // MARK: WalletsViewController
            
            container.register { WalletsViewController(account: try! container.resolve()) }
                .resolvingProperties { (container: DependencyContainer, vc: WalletsViewController) in
                    vc.presentLoadWalletScreen = { index in
                        let account = try! container.resolve() as Account
                        let wallets = account.wallets()
                        let name = index.name
                        let laodWalletViewController = try! container.resolve(arguments: name, wallets) as LoadWalletViewController
                        
                        if laodWalletViewController.canBePresented {
                            laodWalletViewController.onLogined = { [weak laodWalletViewController, weak vc] in
                                laodWalletViewController?.dismiss(animated: true) {
                                    vc?.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                            
                            vc.present(laodWalletViewController, animated: true)
                        } else {
                            let alert = UIAlertController.showSpinner(message: "Loading wallet - \(index.name)")
                            vc.present(alert, animated: true)
                            
                            
                            wallets.loadWallet(withName: name)
                                .then { [weak vc] in
                                    alert.dismiss(animated: true) {
                                        vc?.navigationController?.popToRootViewController(animated: true)
                                    }
                                }.catch { [weak vc] error in
                                    alert.dismiss(animated: true) {
                                        vc?.showError(error)
                                    }
                            }
                        }
                    }
                    
                    vc.presentNewWalletScreen = { [weak vc] in
                        let navController = UINavigationController()
                        let account = try! container.resolve() as Account
                        let signUpFlow = try! container.resolve(arguments: navController, account.wallets()) as SignUpFlow
                        signUpFlow.finalHandler = {
                            navController.dismiss(animated: true) {
                                vc?.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                        
                        signUpFlow.changeRoute(.addNewWallet)
                        vc?.present(signUpFlow.currentViewController, animated: true)
                    }
                    
                    vc.presentSeedWalletScreen = { index in
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        
                        if verifyPinPasswordViewController.canBePresented {
                            let navController = UINavigationController(rootViewController: verifyPinPasswordViewController)
                            verifyPinPasswordViewController.onVerified = { [weak verifyPinPasswordViewController] in
                                let account = try! container.resolve() as Account
                                let wallets = account.wallets()
                                wallets.fetchSeed(for: index)
                                    .then { seed -> Void in
                                        let seedViewController = try! container.resolve(arguments: seed, index.name) as SeedViewController
                                        seedViewController.finishHandler = { [weak seedViewController] in
                                            seedViewController?.dismiss(animated: true) {
                                                navController.viewControllers = []
                                            }
                                        }
                                        
                                        navController.setNavigationBarHidden(false, animated: false)
                                        navController.pushViewController(seedViewController, animated: true)
                                    }.catch { error in
                                        verifyPinPasswordViewController?.showError(error)
                                }
                            }
                            
                            vc.present(navController, animated: true)
                        } else {
                            let account = try! container.resolve() as Account
                            let wallets = account.wallets()
                            wallets.fetchSeed(for: index)
                                .then { seed -> Void in
                                    let seedViewController = try! container.resolve(arguments: seed, index.name) as SeedViewController
                                    let navController = UINavigationController(rootViewController: seedViewController)
                                    seedViewController.finishHandler = { [weak seedViewController] in
                                        seedViewController?.dismiss(animated: true) {
                                            navController.viewControllers = []
                                        }
                                    }
                                    
                                    vc.present(navController, animated: true)
                                }.catch { error in
                                    vc.showError(error)
                            }
                        }
                    }
                    
                    vc.presentRemoveWalletScreen = { [weak vc] index, completionHandler in
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        verifyPinPasswordViewController.onVerified = {
                            let account = try! container.resolve() as Account
                            let wallets = account.wallets()
                            let alert = UIAlertController.showSpinner(message: "Removing wallet")
                            
                            if verifyPinPasswordViewController.canBePresented {
                                verifyPinPasswordViewController.present(alert, animated: true)
                            } else {
                                vc?.present(alert, animated: true)
                            }
                            
                            wallets.removeWallet(withIndex: index)
                                .then { _ in
                                    alert.dismiss(animated: false) {
                                        verifyPinPasswordViewController.dismiss(animated: true)
                                        completionHandler?()
                                    }
                                }.catch { error in
                                    alert.dismiss(animated: false) {
                                        verifyPinPasswordViewController.showError(error)
                                        completionHandler?()
                                    }
                            }
                        }
                        
                        vc?.present(verifyPinPasswordViewController, animated: true)
                    }
                }
            
            // MARK: LoadWalletViewController
            
            container.register { (name: String, wallets: Wallets) in
                LoadWalletViewController(
                    walletName: name,
                    wallets: wallets as WalletsLoadable,
                    verifyPasswordViewController: try! container.resolve() as VerifyPinPasswordViewController)
                }
            
            // MARK: VerifyPinPasswordViewController
            
            container.register {
                VerifyPinPasswordViewController(
                    account: try! container.resolve() as AccountImpl,
                    pinPasswordViewController: try! container.resolve(arguments: true) as PinPasswordViewController)
            }
            
            // MARK: ChangePasswordViewController

            container.register { ChangePasswordViewController(
                account: try! container.resolve() as Account,
                pinPasswordViewController: try! container.resolve(arguments: true) as PinPasswordViewController)
            }
            
            // MARK: TransactionDetailsViewController
            
            container.register { (tx: TransactionDescription) in TransactionDetailsViewController(transaction: tx) }
            
            // MARK: NodeSettingsViewController
            
            container.register { NodeSettingsViewController(account: try! container.resolve() as Account) }
            
            // MARK: DisclaimerViewController
            
            container.register { DisclaimerViewController() }
            
            // MARK: RecoveryWalletOptionsViewController
            
            container.register { RecoveryWalletOptionsViewController() }
            
            // MARK: RecoveryWalletFromKeysViewController
            
            container.register { (wallets: Wallets) in RecoveryWalletFromKeysViewController(wallets: wallets) }
            
            // Flows
            
            container.register { rootViewController, wallets in  SignUpFlow(rootViewController: rootViewController, wallets: wallets) }
            container.register { MainFlow(rootViewController: UINavigationController(), wallet: try! container.resolve() as WalletProxy) }
            container.register { RootFlow(window: $0, account: try! container.resolve() as AccountImpl) }
        }
    }
}
