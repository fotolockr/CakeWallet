//
//  WalletProxy.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit
import FontAwesome_swift

private let backgroundConnectionQueue = DispatchQueue(
    label: "io.cakewallet.backgroundConnectionQueue",
    qos: .utility,
    attributes: .concurrent)
let backgroundConnectionTimerQueue = DispatchQueue(
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
        listeners = []
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
    
    func checkConnection(withTimeout timeout: UInt32) -> Bool {
        return origin.checkConnection(withTimeout: timeout)
    }
    
    private func observeOrigin() {
        origin.observe { [weak self] change, origin in
            DispatchQueue.main.async {
                self?.listeners.forEach { $0(change, origin) }
            }
        }
    }
    
    private func checkNodeConnection(_ connectionSettings: ConnectionSettings) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let urlString = "http://\(connectionSettings.uri)/json_rpc"
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let requestBody = [
                "jsonrpc": "2.0",
                "id": "0",
                "method": "get_info"
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                reject(error)
            }
            
            let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        reject(error)
                        return
                    }
                    
                    guard let data = data else {
                        fulfill(false)
                        return
                    }
                    
                    if
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let result = decoded["result"] as? [String: Any],
                        let status = result["status"] as? String {
                        let res = status.lowercased() == "OK".lowercased()
                        fulfill(res)
                    } else {
                        fulfill(false)
                    }
                } catch {
                    reject(error)
                }
            }
            
            connection.resume()
        }
    }
    
    private func onWalletChange() {
        // FIX-ME: Refactor me please...
        
        var isConnecting = false
        var isFirstConnect = true
        timer?.suspend()
        timer = UTimer(deadline: .now(), repeating: .seconds(3), queue: backgroundConnectionTimerQueue)
        timer?.listener = { [weak self] in
            let settings = ConnectionSettings.loadSavedSettings()
            guard let status = self?.status else { return }
            let nodeIsAvailable = checkConnectionSync(with: settings)
            let connect = {
                guard !isConnecting && !isAutoNodeSwitching else { return }
                isConnecting = true
                self?.status = .startUpdating
                self?.connect(withSettings: settings, updateState: false)
                    .always {
                        if isFirstConnect {
                            isFirstConnect = false
                        }
                        
                        isConnecting = false
                    }.then { _ -> Void in
                        self?.status = .connected
                        self?.startUpdate()
                    }.catch { error in
                        print("Connection error: \(error.localizedDescription)")
                        switch status {
                        case .failedConnection(_):
                            self?.status = .failedConnectionNext
                        default:
                            let now = Date()
                            self?.status = .failedConnection(now)
                        }
                }
            }
            if !nodeIsAvailable {
                switch status {
                case .failedConnectionNext:
                    self?.status = .failedConnectionNext
                case .failedConnection(_):
                    self?.status = .failedConnectionNext
                default:
                    let now = Date()
                    self?.status = .failedConnection(now)
                }
            } else if self?.isConnected == true || isFirstConnect {
                switch status {
                case .connected:
                    self?.startUpdate()
                case .notConnected, .failedConnection(_), .failedConnectionNext:
                    _ = connect()
                default:
                    break
                }
            } else {
                switch status {
                case .failedConnectionNext:
                    self?.status = .failedConnectionNext
                case .failedConnection(_):
                    self?.status = .failedConnectionNext
                default:
                    let now = Date()
                    self?.status = .failedConnection(now)
                }
            }
            
//            if !isConnected {
//                print("Not connected")
//
//            } else {
//                print(status)
//            }
            
//            if isFirstConnect || (!isConnecting && !isConnected) {
//                guard !isAutoNodeSwitching else {
//                    return
//                }
//
//                isConnecting = true
//                self?.connect(withSettings: settings, updateState: false)
//                    .always {
//                        if isFirstConnect {
//                            isFirstConnect = false
//                        }
//                    }.then { _ -> Void in
//                        self?.startUpdate()
//                        isConnecting = false
//                        self?.status = .connected
//                    }.catch { error in
//                        print("Connection error: \(error.localizedDescription)")
//                        switch status {
//                        case .failedConnection(_):
//                            self?.status = .failedConnectionNext
//                        default:
//                            let now = Date()
//                            self?.status = .failedConnection(now)
//                        }
//
//                        isConnecting = false
//                }
//            } else if canConnect {
//                switch status {
//                case .startUpdating, .updated, .updating(_):
//                    break
//                default:
//                    self?.startUpdate()
//                }
//            } else if isConnecting && !canConnect {
//                isConnecting = false
//
//                if let status = self?.status {
//                    switch status {
//                    case .failedConnection, .notConnected, .failedConnectionNext:
//                        break
//                    default:
//                        let now = Date()
//                        self?.status = .failedConnection(now)
//                    }
//                }
//            }
        }
        
        timer?.resume()
    }
}
