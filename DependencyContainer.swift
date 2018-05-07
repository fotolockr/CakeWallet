//
//  DependencyContainer.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation
import Dip
import SwiftKeychainWrapper
import PromiseKit

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
                }.implements(
                    AuthenticationProtocol.self,
                    Account.self,
                    AccountSettingsConfigurable.self,
                    CurrencySettingsConfigurable.self)
            
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
            
            container.register(.singleton) { MoneroRateTicker(account: try! container.resolve() as AccountImpl) }
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
            
            // MARK: ExchangeResultViewController
            
            container.register { (trade: ExchangeTrade, amountStr: String) in
                ExchangeResultViewController(
                    account: try! container.resolve() as AccountImpl,
                    trade: trade,
                    amountStr: amountStr)
                }.resolvingProperties { (container, vc: ExchangeResultViewController) in
                    vc.presentVerifyPinScreen = { handler in
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        verifyPinPasswordViewController.modalPresentationStyle = .overFullScreen
                        verifyPinPasswordViewController.onVerified = {
                            verifyPinPasswordViewController.dismiss(animated: true) {
                                handler()
                            }
                        }
                        
                        vc.present(verifyPinPasswordViewController, animated: true)
                    }
            }
            
            // MARK: AddWalletViewController
            
            container.register { AddWalletViewController() }
            
            // MARK: NewWalletViewController
            
            container.register { (wallets: Wallets) in  NewWalletViewController(wallets: wallets as WalletsCreating) }
            
            // MARK: RecoveryViewController
            
            container.register { (wallets: Wallets) in  RecoveryViewController(wallets: wallets as WalletsRecoverable) }
            container.register { (name: String, seed: String) in  RecoveryViewController(wallets: (try! container.resolve() as Account).wallets(), name: name, seed: seed) }
            
            // MARK: SeedViewController
            
            container.register { SeedViewController(wallet: try! container.resolve() as WalletProxy) }
            container.register { (wallet: WalletProtocol) in SeedViewController(wallet: wallet) }
            container.register { (seed: String, name: String) in SeedViewController(seed: seed, name: name) }
            
            // MARK: SummaryViewController
            
            container.register { (wallet: WalletProtocol) in
                DashboardViewController(account: try! container.resolve() as AccountImpl, wallet: wallet, rateTicker: try! container.resolve() as RateTicker)
            }
            
            container.register {
                DashboardViewController(
                    account: try! container.resolve() as AccountImpl,
                    wallet: (try! container.resolve() as WalletProxy) as WalletProtocol,
                    rateTicker: try! container.resolve() as RateTicker)
                }.resolvingProperties { (conteiner, vc: DashboardViewController) in
                    vc.presentTransactionDetails = { [weak vc] transaction in
                        let transactionDetailsViewController = TransactionDetailsViewController(transaction: transaction)
                        vc?.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
                    }
                    
                    vc.presentTransactionsList = { [weak vc] in
                        let transactionsList = try! container.resolve() as TransactionsListViewController
                        vc?.navigationController?.pushViewController(transactionsList, animated: true)
                    }
                }
            
            // MARK: ReceiveViewController
            
            container.register { (wallet: WalletProtocol) in ReceiveViewController(wallet: wallet) }
            container.register { ReceiveViewController(wallet: try! container.resolve() as WalletProxy) }
            
            // MARK: SendViewController
            
            container.register {
                SendViewController(
                    account: try! container.resolve() as AccountImpl,
                    estimatedFeeCalculation: (try! container.resolve() as Account).wallets(),
                    transactionCreation:  (try! container.resolve() as Account).currentWallet,
                    rateTicker: try! container.resolve() as RateTicker)
            }
            
            container.register { (address: String, amount: Amount) in
                SendViewController(
                    address: address,
                    amount: amount,
                    account: try! container.resolve() as AccountImpl,
                    estimatedFeeCalculation: (try! container.resolve() as Account).wallets(),
                    transactionCreation:  (try! container.resolve() as Account).currentWallet,
                    rateTicker: try! container.resolve() as RateTicker)
            }
            
            // MARK: UnlockViewController
            
            container.register { (account: Account & AuthenticationProtocol) in
                LoginViewController(account: account)
                }.resolvingProperties { (container, vc: LoginViewController) in
                    vc.onShowWalletsScreen = { [weak vc] in
                        let walletsScreen = try! container.resolve() as WalletsViewController
                        let nav = UINavigationController(rootViewController: walletsScreen)
                        walletsScreen.finishHandler = { [weak nav] in
                            nav?.dismiss(animated: true) {
                                vc?.onLogined?()
                            }
                        }
                        vc?.present(nav, animated: true)
                    }
                    
                    vc.onRecoveryWallet = { [weak vc] name in
                        let alert = UIAlertController.showSpinner(message: "Starting recovery")
                        let account = try! container.resolve() as Account
                        let wallets = account.wallets()
                        wallets.fetchSeed(for: WalletIndex(name: name))
                            .then { seed in
                                alert.dismiss(animated: true) {
                                    let recoveryVC = try! container.resolve(arguments: name, seed) as RecoveryViewController
                                    recoveryVC.onPrepareRecovery = {
                                        return wallets.isExistWallet(withName: name)
                                            .then { isExist in
                                                return isExist
                                                    ? wallets.moneroWalletGateway.remove(withName: name, password: "")
                                                    : Promise(value: ())
                                        }
                                    }
                                    let nav = UINavigationController(rootViewController: recoveryVC)
                                    recoveryVC.onRecovered = {
                                        vc?.onLogined?()
                                    }
                                    vc?.present(nav, animated: true)
                                }
                            }.catch { error in
                                alert.dismiss(animated: true) {
                                    vc?.showError(error)
                                }
                        }
                        vc?.present(alert, animated: true)
                    }
            }
            
            // MARK: AuthenticateViewController
            
            container.register { (account: Account & AuthenticationProtocol) in
                AuthenticateViewController(account: account)
            }
            
            // MARK: WalletKeyViewController
            
            container.register { WalletKeyViewController(wallet: try! container.resolve() as WalletProxy) }
            container.register { (wallet: WalletProtocol) in WalletKeyViewController(wallet: wallet) }
            container.register { (wallet) in WalletKeyViewController(wallet: wallet) }
            container.register { (name: String, viewKey: WalletKey, spendKey: WalletKey) in WalletKeyViewController(name: name, viewKey: viewKey, spendKey: spendKey) }
            
            // MARK: SettingsViewController
            
            container.register {
                SettingsViewController(
                    accountSettings: try! container.resolve() as AccountImpl,
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
                        let nodeSettingsViewController = try! container.resolve() as NodesListViewController
                        vc?.navigationController?.pushViewController(nodeSettingsViewController, animated: true)
                    }
                    
                    vc.presentWalletKeys = { [weak vc] in
                        let verifyPinPasswordViewController = try! container.resolve() as VerifyPinPasswordViewController
                        
                        if verifyPinPasswordViewController.canBePresented {
                            verifyPinPasswordViewController.onVerified = {
                                let walletKeyViewController = try! container.resolve() as WalletKeyViewController
                                let navController = UINavigationController(rootViewController: walletKeyViewController)
                                verifyPinPasswordViewController.dismiss(animated: false) {
                                    vc?.present(navController, animated: true)
                                }
                            }
                            
                            vc?.present(verifyPinPasswordViewController, animated: true)
                        } else {
                            let walletKeyViewController = try! container.resolve() as WalletKeyViewController
                            let navController = UINavigationController(rootViewController: walletKeyViewController)
                            vc?.present(navController, animated: true)
                        }
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
                    
                    vc.presentDonation = {
                        let donationViewController = try! container.resolve() as DonationViewController
                        vc.navigationController?.pushViewController(donationViewController, animated: true)
                    }
                }
            
            // MARK: WalletsViewController
            
            container.register { WalletsViewController(account: try! container.resolve()) }
                .resolvingProperties { (container: DependencyContainer, vc: WalletsViewController) in
                    let back = { [weak vc] in
                        if let rootVc = vc?.navigationController?.viewControllers.first {
                            rootVc.tabBarController?.selectedIndex = 0
                            vc?.navigationController?.popToRootViewController(animated: false)
                        }
                    }
                    
                    vc.presentLoadWalletScreen = { [weak vc] index in
                        let account = try! container.resolve() as Account
                        let wallets = account.wallets()
                        let name = index.name
                        let laodWalletViewController = try! container.resolve(arguments: name, wallets) as LoadWalletViewController
                        
                        if laodWalletViewController.canBePresented {
                            laodWalletViewController.onLogined = { [weak laodWalletViewController] in
                                laodWalletViewController?.dismiss(animated: true) {
                                    if let finishHandler = vc?.finishHandler {
                                        finishHandler()
                                    } else {
                                        back()
                                    }
                                }
                            }
                            
                            vc?.present(laodWalletViewController, animated: true)
                        } else {
                            let alert = UIAlertController.showSpinner(message: "Loading wallet - \(index.name)")
                            vc?.present(alert, animated: true)
                            
                            
                            wallets.loadWallet(withName: name)
                                .then {
                                    alert.dismiss(animated: true) {
                                        if let finishHandler = vc?.finishHandler {
                                            finishHandler()
                                        } else {
                                            back()
                                        }
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
                            if let finishHandler = vc?.finishHandler {
                                finishHandler()
                            } else {
                                navController.dismiss(animated: true) {
                                    back()
                                }
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
                }.resolvingProperties { (container, vc: LoadWalletViewController) in
                    vc.onRecoveryWallet = { [weak vc] name in
                        let alert = UIAlertController.showSpinner(message: "Starting recovery")
                        let account = try! container.resolve() as Account
                        let wallets = account.wallets()
                        wallets.fetchSeed(for: WalletIndex(name: name))
                            .then { seed in
                                alert.dismiss(animated: true) {
                                    let recoveryVC = try! container.resolve(arguments: name, seed) as RecoveryViewController
                                    recoveryVC.onPrepareRecovery = {
                                        return wallets.isExistWallet(withName: name)
                                            .then { isExist in
                                                return isExist
                                                    ? wallets.moneroWalletGateway.remove(withName: name, password: "")
                                                    : Promise(value: ())
                                        }
                                    }
                                    let nav = UINavigationController(rootViewController: recoveryVC)
                                    recoveryVC.onRecovered = {
                                        vc?.onLogined?()
                                    }
                                    vc?.present(nav, animated: true)
                                }
                            }.catch { error in
                                alert.dismiss(animated: true) {
                                    vc?.showError(error)
                                }
                        }
                        vc?.present(alert, animated: true)
                    }
                }
            
            // MARK: VerifyPinPasswordViewController
            
            container.register {
                VerifyPinPasswordViewController(
                    account: try! container.resolve() as AccountImpl,
                    pinPasswordViewController: try! container.resolve(arguments: true) as PinPasswordViewController)
            }
            
            // MARK: ChangePasswordViewController

            container.register { ChangePasswordViewController(
                account: try! container.resolve() as AccountImpl,
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
            
            // MARK: DonationViewController
            
            container.register { DonationViewController(canSend: !(try! container.resolve () as WalletProxy).isWatchOnly) }
            
            // MARK: TransactionsListViewController
            
            container.register {
                TransactionsListViewController(wallet: try! container.resolve() as WalletProxy)
                }.resolvingProperties { (container, vc: TransactionsListViewController) in
                    vc.presentTransactionDetails = { [weak vc] transaction in
                        let transactionDetailsViewController = TransactionDetailsViewController(transaction: transaction)
                        vc?.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
                    }
            }
            
            //  MARK: ExchangeViewController
            
            container.register { ExchangeViewController(
                account: try! container.resolve() as AccountImpl,
                wallet: try! container.resolve() as WalletProxy,
                transactionCreation: try! container.resolve() as WalletProxy)
            }
            //  MARK: BuyViewController
            
            container.register { BuyViewController(wallet: try! container.resolve() as WalletProxy) }
            
            // MARK: ServicesViewController
            
            container.register { ServicesViewController(
                exchangeViewController: try! container.resolve() as ExchangeViewController,
                buyViewController: try! container.resolve() as BuyViewController)
            }
            
            // MARK: NewNodeSettingsViewController
            
            container.register {
                NewNodeSettingsViewController(nodesList: $0)
            }
            
            // MARK: NodesListViewController
            
            container.register {
                NodesListViewController(
                    account: try! container.resolve() as AccountImpl,
                    nodesList: NodesList.shared)
                }.resolvingProperties({ (container, vc: NodesListViewController) in
                    vc.presentNewNodeScreen = { [weak vc] in
                        if let _vc = vc {
                            let newNodeVC = try! container.resolve(arguments: _vc.nodesList) as NewNodeSettingsViewController
                            _vc.navigationController?.pushViewController(newNodeVC, animated: true)
                        }
                    }
                })
            
            
            // MARK: NodeConnectionControl
            
            container.register {
                NodeConnectionControl(account: try! container.resolve() as AccountImpl, nodesList: NodesList.shared)
            }
            
            // Flows
            
            container.register { rootViewController, wallets in  SignUpFlow(rootViewController: rootViewController, wallets: wallets) }
            container.register { MainFlow(rootViewController: UITabBarController(viewControllers: [
                    UINavigationController(rootViewController: try! container.resolve() as DashboardViewController),
                    UINavigationController(rootViewController: try! container.resolve() as SendViewController),
                    UINavigationController(rootViewController: try! container.resolve() as ReceiveViewController),
                    UINavigationController(rootViewController: try! container.resolve() as ServicesViewController),
                    UINavigationController(rootViewController: try! container.resolve() as SettingsViewController)
                ])) }
            container.register { RootFlow(window: $0, account: try! container.resolve() as AccountImpl) }
        }
    }
}
