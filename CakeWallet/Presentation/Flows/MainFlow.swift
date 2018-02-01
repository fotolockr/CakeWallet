//
//  MainFlow.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class MainFlow: Flow {
    enum Route: RouteType {
        case start
        case settings
    }
    
    var currentViewController: UIViewController {
        return rootViewController
    }
    var finalHandler: Flow.FinishHandler
    private let rootViewController: UINavigationController
    private let wallet: WalletProtocol
    private weak var dashboardViewController: DashboardViewController?
    
    init(rootViewController: UINavigationController, wallet: WalletProtocol) {
        self.rootViewController = rootViewController
        self.wallet = wallet
    }
    
    func changeRoute(_ route: Route) {
        switch route {
        case .start:
            rootViewController.pushViewController(initDashboaradVC(), animated: true)
        case .settings:
            rootViewController.pushViewController(initSettings(), animated: true)
        }
    }
    
    private func initDashboaradVC() -> DashboardViewController {
        if let dashboardViewController = self.dashboardViewController {
            return dashboardViewController
        }
        
        let dashboardViewController = try! container.resolve(arguments: wallet) as DashboardViewController
        
        dashboardViewController.presentReceiveScreen = { [weak dashboardViewController] in
            let receiveViewController = try! container.resolve(arguments: self.wallet) as ReceiveViewController
            dashboardViewController?.presentModal(receiveViewController)
        }
        
        dashboardViewController.presentSettingsScreen = {
            let settingsViewController = try! container.resolve() as SettingsViewController
            self.rootViewController.pushViewController(settingsViewController, animated: true)
        }
        
        dashboardViewController.presentTransactionDetails = { transaction in
            let transactionDetailsViewController = TransactionDetailsViewController(transaction: transaction)
            self.rootViewController.pushViewController(transactionDetailsViewController, animated: true)
        }
        
        dashboardViewController.presentSendScreen = { [weak dashboardViewController] in
            let sendViewController = try! container.resolve() as SendViewController
            dashboardViewController?.presentModal(sendViewController)
        }
        
        self.dashboardViewController = dashboardViewController
        return dashboardViewController
    }
    
    private func initSettings() -> SettingsViewController {
        let settingsViewController = try! container.resolve() as SettingsViewController
        return settingsViewController
    }
}
