//
//  WalletProxy.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

private let backgroundConnectionQueue = DispatchQueue(
    label: "io.cakewallet.backgroundConnectionQueue",
    qos: .utility,
    attributes: .concurrent)
private let backgroundConnectionTimerQueue = DispatchQueue(
    label: "io.cakewallet.backgroundConnectionTimerQueue",
    qos: .background,
    attributes: .concurrent)
private let failedConnectionDelay: TimeInterval = 120 // 2 mins
private var timer: UTimer?

final class WalletProxy: Proxable, WalletProtocol {
    var name: String {
        return origin.name
    }
    var balance: Amount {
        return origin.balance
    }
    var unlockedBalance: Amount {
        return origin.unlockedBalance
    }
    var address: String {
        return origin.address
    }
    var currentHeight: UInt64 {
        return origin.currentHeight
    }
    var seed: String {
        return origin.seed
    }
    var status: NetworkStatus {
        get {
            return origin.status
        }
        
        set {
            origin.status = newValue
        }
    }
    var isReadyToReceive: Bool {
        return origin.isReadyToReceive
    }
    var isConnected: Bool {
        return origin.isConnected
    }
    var spendKey: WalletKey {
        return origin.spendKey
    }
    var viewKey: WalletKey {
        return origin.viewKey
    }
    var isWatchOnly: Bool {
        return origin.isWatchOnly
    }
    
    private(set) var origin: WalletProtocol
    private var listeners: [ChangeHandler]
    
    init(origin: WalletProtocol) {
        self.origin = origin
        self.listeners = []
    }
    
    func `switch`(origin: WalletProtocol) {
//        self.origin.close()
//        self.origin.clear()
        let oldWallet = self.origin
        self.origin = origin
        observeOrigin()
        onWalletChange()
        oldWallet.close()
        oldWallet.clear()
    }
    
    func save() -> Promise<Void> {
        return origin.save()
    }
    
    func connect(withSettings settings: ConnectionSettings, updateState: Bool) -> Promise<Void> {
        return origin.connect(withSettings: settings, updateState: updateState)
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void> {
        return origin.changePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    func createTransaction(to address: String, withPaymentId paymentId: String, amount: Amount?,
                           priority: TransactionPriority) -> Promise<PendingTransaction> {
        return origin.createTransaction(to: address, withPaymentId: paymentId, amount: amount, priority: priority)
    }
    
    func close() {
        origin.close()
    }
    
    func observe(_ handler: @escaping (MoneroWalletChange, WalletProtocol) -> Void) {
        listeners.append(handler)
        handler(.reset, self)
    }
    
    func startUpdate() {
        origin.startUpdate()
    }
    
    func transactionHistory() -> TransactionHistory {
        return origin.transactionHistory()
    }
    
    func clear() {
        origin.clear()
    }
    
    func integratedAddress(for paymentId: String) -> String {
        return origin.integratedAddress(for: paymentId)
    }
    
    private func observeOrigin() {
        origin.observe { [weak self] change, origin in
            DispatchQueue.main.async {
                self?.listeners.forEach { $0(change, origin) }
            }
        }
    }
    
    private func onWalletChange() {
        // FIX-ME: Refactor me please...
        
        var isConnecting = false
        var isFirstConnect = true
        timer?.suspend()
        timer = UTimer(deadline: .now(), repeating: .seconds(3), queue: backgroundConnectionTimerQueue)
        timer?.listener = { [weak self] in            
            guard
                let isConnected = self?.isConnected,
                let status = self?.status else {
                return
            }
            
            if isFirstConnect || (!isConnected && !isConnecting) {
                guard let settings = ConnectionSettings.loadSavedSettings() else {
                    return
                }
                
                isConnecting = true
                
                self?.connect(withSettings: settings, updateState: false)
                    .always {
                        if isFirstConnect {
                            isFirstConnect = false
                        }
                    }.then { _ -> Void in
                        self?.startUpdate()
                        isConnecting = false
                        self?.status = .connected
                    }.catch { error in
                        print("Connection error: \(error.localizedDescription)")
                        
                        switch status {
                        case .failedConnection(_):
                            break
                        default:
                            let now = Date()
                            self?.status = .failedConnection(now)
                        }
                        
                        isConnecting = false
                }
            } else if isConnected {
                switch status {
                case .startUpdating, .updated, .updating(_):
                    break
                default:
                    self?.startUpdate()
                }
            } else if isConnecting && !isConnected {
                isConnecting = false
                
                if let status = self?.status {
                    switch status {
                    case .failedConnection, .notConnected:
                        break
                    default:
                        let now = Date()
                        self?.status = .failedConnection(now)
                    }
                }
            }
        }
        
        timer?.resume()
    }
}
