//
//  NodeConnectionControl.swift
//  CakeWallet
//
//  Created by Cake Technologies on 07.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

private(set) var isAutoNodeSwitching = false

final class NodeConnectionControl {
    private let accountSettings: AccountSettingsConfigurable
    private let wallet: WalletProtocol
    private let nodesList: NodesList
    private var failedConnectionsAlertShown: Bool
    private var banned: [ConnectionSettings]
    private var bannedClearTime: TimeInterval
    private var failedConnections: Int {
        didSet {
            print("failedConnections \(failedConnections)")
        }
    }
    
    convenience init(account: AccountImpl, nodesList: NodesList) {
        self.init(accountSettings: account, wallet: account.currentWallet, nodesList: nodesList)
    }
    
    init(accountSettings: AccountSettingsConfigurable, wallet: WalletProtocol, nodesList: NodesList) {
        self.accountSettings = accountSettings
        self.wallet = wallet
        self.nodesList = nodesList
        failedConnectionsAlertShown = false
        failedConnections = 0
        banned = []
        bannedClearTime = 0
    }
    
    func start() {
        wallet.observe { change, wallet in
            switch change {
            case let .changedStatus(status):
                switch status {
                case .failedConnectionNext:
                    self.failedConnections += 1
                    self.handler()
                case .failedConnection(_):
                    self.failedConnections += 1
                    self.handler()
                default:
                    if self.failedConnections > 0 {
                        self.failedConnections = 0
                        self.failedConnectionsAlertShown = false
                    }
                    break
                }
            default:
                break
            }
        }
        
        let timer = UTimer(deadline: .now(), repeating: .seconds(360), queue: backgroundConnectionTimerQueue)
        timer.listener = { [weak self] in
            self?.banned = []
        }
    }
    
    private func handler() {
        guard failedConnections >= 3 else {
            return
        }
        
        if accountSettings.autoSwitchNode {
            autoSwitchNode()
        } else {
            switchNode()
        }
    }
    
    private func autoSwitchNode() {
        isAutoNodeSwitching = true
        let now = Date().timeIntervalSince1970
        
        if banned.count == nodesList.count {
            banned = []
        } else if  now - bannedClearTime > 360 {
            bannedClearTime = now
            banned = []
        }
        
        when(fulfilled: nodesList.map{ $0.connect() })
            .always { isAutoNodeSwitching = false }
            .then { res -> Void in
                for (canConnect, node) in res {
                    if canConnect && self.banned.index(of: node) == nil {
                        self.wallet.connect(withSettings: node)
                            .then { node.save() }
                            .catch { [weak self] error in
                                self?.banned.append(node)
                                print(error)
                        }
                        break
                    }
                }
            }.catch { error in print(error) }
    }
    
    private func switchNode() {
        if !failedConnectionsAlertShown {
            let alert = UIAlertController(title: "Connection problems", message: "Cannot connect to remote node. Please switch to another.", preferredStyle: .alert)
            alert.modalPresentationStyle = .overFullScreen
            let switchAction = UIAlertAction(title: "Switch", style: .default) { _ in
                guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
                    return
                }
                
                let nodeSettingsVC = try! container.resolve() as NodesListViewController
                nodeSettingsVC.modalPresentationStyle = .overFullScreen
                let navController = UINavigationController(rootViewController: nodeSettingsVC)
                rootVC.present(navController, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(switchAction)
            alert.addAction(cancelAction)
            failedConnectionsAlertShown = true
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}
