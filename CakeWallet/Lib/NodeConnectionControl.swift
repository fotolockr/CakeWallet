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
    
    func getRandomAvailableNode() -> Promise<ConnectionSettings?> {
        return getAvailableNodes()
            .then { nodes in
                guard !nodes.isEmpty else {
                    return Promise(value: nil)
                }
                
                let i = Int(arc4random_uniform(UInt32(nodes.count)))
                return Promise(value: nodes[i])
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
        guard !isAutoNodeSwitching else { return }
        isAutoNodeSwitching = true
        let now = Date().timeIntervalSince1970
        
        if banned.count == nodesList.count {
            banned = []
        } else if  now - bannedClearTime > 360 {
            bannedClearTime = now
            banned = []
        }
        
        nodesPingQueue.async {
            for nodeSettings in self.nodesList {
                let canConnect = checkConnectionSync(with: nodeSettings)
                
                if canConnect {
                    self.wallet.connect(withSettings: nodeSettings)
                        .always { isAutoNodeSwitching = false }
                        .then { nodeSettings.save() }
                        .catch { [weak self] error in
                            self?.banned.append(nodeSettings)
                            print(error)
                    }
                    
                    break
                }
            }
        }
    }
    
    private func getAvailableNodes() -> Promise<[ConnectionSettings]> {
        return when(fulfilled: nodesList.map{ $0.connect() })
            .then { res -> [ConnectionSettings] in
                return res.map { canConnect, node in
                    return canConnect
                        ? node
                        : nil
                    }.compactMap({ $0 })
        }
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
