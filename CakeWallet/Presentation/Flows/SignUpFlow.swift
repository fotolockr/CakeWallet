//
//  SignUpFlow.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class SignUpFlow: Flow {
    enum Route: RouteType {
        case start
        case setupPinPassword
        case addPinPassword
        case addNewWallet
        case newWallet
        case recoveryWallet
    }
    
    var currentViewController: UIViewController {
        return rootViewController
    }
    private let rootViewController: UINavigationController
    private var wallets: Wallets
    var finalHandler: Flow.FinishHandler
    
    init(rootViewController: UINavigationController, wallets: Wallets) {
        self.rootViewController = rootViewController
        self.wallets = wallets
    }
    
    func changeRoute(_ route: Route) {
        switch route {
        case .start:
            setupWelcomeRoute()
        case .addPinPassword:
            break
        case .addNewWallet:
            setAddWalletRoute()
        case .setupPinPassword:
            setSetupPinPasswordRoute()
        case .newWallet:
            setNewWalletRoute()
        case .recoveryWallet:
            setRecoverWalletRoute()
        }
    }
    
    func setupWelcomeRoute() {
        let welcomeViewController = try! container.resolve() as WelcomeViewController
        welcomeViewController.start = { self.changeRoute(Route.setupPinPassword) }
        rootViewController.pushViewController(welcomeViewController, animated: true)
    }
    
    func setAddWalletRoute() {
        let addWalletViewController = try! container.resolve() as AddWalletViewController
        addWalletViewController.presentRecoveryWallet = { self.changeRoute(.recoveryWallet) }
        addWalletViewController.presentCreateNewWallet = { self.changeRoute(.newWallet) }
        rootViewController.pushViewController(addWalletViewController, animated: true)
    }
    
    func setSetupPinPasswordRoute() {
        let setupPinPasswordViewController = try! container.resolve() as SetupPinPasswordViewController
        setupPinPasswordViewController.setuped = { self.changeRoute(.addNewWallet) }
        rootViewController.pushViewController(setupPinPasswordViewController, animated: true)
    }
    
    func setNewWalletRoute() {
        let newWalletViewController = try! container.resolve(arguments: wallets) as NewWalletViewController
        newWalletViewController.onWalletCreated = { [weak newWalletViewController] seed in
            guard let newWalletViewController = newWalletViewController else {
                return
            }
            
            UIAlertController.showInfo(
                message: "The next page will show you a seed. Please write these down just in case you lose or wipe your phone.\nYou can also see the seed again in the settings menu.",
                presentOn: newWalletViewController) { _ in
                    self.setSeedDisplayingRoute(seed: seed)
            }
        }
        rootViewController.pushViewController(newWalletViewController, animated: true)
    }
    
    func setRecoverWalletRoute() {
        let recoverWalletViewController = try! container.resolve(arguments: wallets) as RecoveryViewController
        recoverWalletViewController.onRecovered = { self.finalHandler?() }
        rootViewController.pushViewController(recoverWalletViewController, animated: true)
    }
    
    func setSeedDisplayingRoute(seed: String) {
        let seedViewController = try! container.resolve(arguments: seed) as SeedViewController
        seedViewController.finishHandler = { self.finalHandler?() }
        rootViewController.pushViewController(seedViewController, animated: true)
    }
}
