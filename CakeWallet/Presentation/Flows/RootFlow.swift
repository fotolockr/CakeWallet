//
//  RootFlow.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import Dip

final class RootFlow: Flow {
    enum Route: RouteType {
        case start
    }
    
    var currentViewController: UIViewController {
        if let viewController = self.window.rootViewController {
            return viewController
        }
        
        let viewController = UIViewController()
        self.window.rootViewController = viewController
        return viewController
    }
    var finalHandler: Flow.FinishHandler
    private let window: UIWindow
    private let account: Account & AuthenticationProtocol
    
    init(window: UIWindow, account: Account & AuthenticationProtocol) {
        self.window = window
        self.account = account
    }
    
    func changeRoute(_ route: Route) {
        switch route {
        case .start:
            guard UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.termsOfUseAccepted) else {
                openTermsOfUse()
                return
            }
            
            start()
        }
    }
    
    private func start() {
        guard account.isLogined() else {
            openSignUpFlow()
            return
        }
        
        openUnlockRoute()
    }
    
    private func openTermsOfUse() {
        let viewController = try! container.resolve() as DisclaimerViewController
        viewController.onAccept = {
            UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.termsOfUseAccepted)
            self.start()
        }
        
        viewController.onCancel = {
            UserDefaults.standard.set(false, forKey: Configurations.DefaultsKeys.termsOfUseAccepted)
            exit(0)
        }
        window.rootViewController = viewController
    }
    
    private func openSignUpFlow() {
        let navigationController = UINavigationController()
        let signUpFlow = try! container.resolve(arguments: navigationController, account.wallets()) as SignUpFlow
        signUpFlow.finalHandler = { self.openMainFlow() }
        window.rootViewController = navigationController
        signUpFlow.changeRoute(.start)
    }
    
    private func openMainFlow() {
        let mainFlow = try! container.resolve() as MainFlow
        self.window.rootViewController = mainFlow.currentViewController
        mainFlow.changeRoute(.start)
    }
    
    private func openUnlockRoute() {
        let loginViewController = try! container.resolve(arguments: account) as LoginViewController
        window.rootViewController = loginViewController
        loginViewController.onLogined = {
            DispatchQueue.main.async {
                self.openMainFlow()
            }
        }
    }
}
