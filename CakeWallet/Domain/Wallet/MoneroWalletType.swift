//
//  MoneroWalletType.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit
import SystemConfiguration

let moneroBlockSize = 1000
private let updateQueue = DispatchQueue(
    label: "io.cakewallet.updateQueue",
    qos: .utility,
    attributes: .concurrent)

final class MoneroWalletType: WalletProtocol {
    static func generatePaymentId() -> String {
        return MoneroWalletAdapter.generatePaymentId()
    }
    
    var name: String {
        return moneroAdapter.name()
    }
    
    var balance: Amount {
        return MoneroAmount(value: moneroAdapter.balance())
    }
    
    var unlockedBalance: Amount {
        return MoneroAmount(value: moneroAdapter.unlockedBalance())
    }
    
    var address: String {
        return moneroAdapter.address()
    }
    
    var seed: String {
        return moneroAdapter.seed()
    }
    
    var isConnected: Bool {
        return moneroAdapter.connectionStatus() != 0
//        if let settings = self.settings {
//            return checkConnectionSync(toUri: settings.uri)
//        } else {
//            return false
//        }
    }
    
    var isUpdateStarted: Bool {
        switch status {
        case .startUpdating, .updated, .updating(_):
            return true
        default:
            return false
        }
    }
    
    var isReadyToReceive: Bool {
        if case .updated = status {
            return true
        } else if isNew && !isRecovery {
            return false
        } else {
            return true
        }
    }
    
    var spendKey: WalletKey {
        return WalletKey(pub: self.moneroAdapter.publicSpendKey(), sec: self.moneroAdapter.secretSpendKey())
    }
    
    var viewKey: WalletKey {
        return WalletKey(pub: self.moneroAdapter.publicViewKey(), sec: self.moneroAdapter.secretViewKey())
    }
    
    var isWatchOnly: Bool {
        return spendKey.sec.range(of: "^0*$", options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    var status: NetworkStatus {
        didSet {
            self.emit(.changedStatus(status))
            
            if case NetworkStatus.updated = status {                
                if isNew {
                    isNew = false
                }
            }
        }
    }
    
    private(set) var currentHeight: UInt64
    
    private(set) var isNew: Bool {
        didSet {
            do {
                try self.keychainStorage.set(
                    value: isNew.description,
                    forKey: KeychainKey.isNew(WalletIndex(name: name)))
                self.emit(.changedIsNew(isNew))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private(set) var isRecovery: Bool
    private var password: String
    private var _blockchainHeight: UInt64
    private var _blockchainHeightUpdateDate: Date?
    private var _isFetchingBlockChainHeight: Bool
    private var listeners: [ChangeHandler]
    private var initialCurrentHeight: UInt64
    private var _moneroTransactionHistory: MoneroTransactionHistory?
    private var settings: ConnectionSettings?
    private let moneroAdapter: MoneroWalletAdapter
    private let keychainStorage: KeychainStorage
    
    init(moneroAdapter: MoneroWalletAdapter, password: String, isRecovery: Bool, keychainStorage: KeychainStorage) {
        self.moneroAdapter = moneroAdapter
        self.currentHeight = 0
        self.password = password
        self.isRecovery = isRecovery
        self.keychainStorage = keychainStorage
        settings = nil
        listeners = []
        status = .notConnected
        isNew = true
        initialCurrentHeight = 0
        _blockchainHeight = 0
        _blockchainHeightUpdateDate = nil
        _isFetchingBlockChainHeight = false
        
        if
            let isNewStr = try? self.keychainStorage.fetch(forKey: .isNew(WalletIndex(name: name))),
            let isNew = Bool(isNewStr) {
            self.isNew = isNew
        }
        
        moneroAdapter.delegate = self
    }
    
    func save() -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.moneroAdapter.save()
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func connect(withSettings settings: ConnectionSettings, updateState: Bool) -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    if updateState {
                        self.status = .connecting
                    }
                    self.settings = settings
                    print(settings.uri)
                    self.moneroAdapter.setDaemonAddress(settings.uri, login: settings.login, password: settings.password)
                    try self.moneroAdapter.connectToDaemon()
                    
                    if updateState {
                        self.status = .connected
                    }
                    
                    
                    fulfill(())
                } catch {
                    if updateState {
                        self.status = .notConnected
                    }
                    
                    reject(error)
                }
            }
        }
    }
    
    func authenticatePassword(_ password: String) -> Bool {
        return self.password == password
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            guard authenticatePassword(oldPassword) else {
                throw WalletError.incorrectPassword
            }
            
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.moneroAdapter.setPassword(newPassword)
                    self.password = newPassword
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func clear() {
        listeners = []
        moneroAdapter.clear()
        moneroAdapter.delegate = nil
    }
    
    func close() {
        self.moneroAdapter.close()
    }
    
    func createTransaction(to address: String, withPaymentId paymentId: String,
                           amount: Amount?, priority: TransactionPriority) -> Promise<PendingTransaction> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let priorityRaw = priority.rawValue
                    let moneroPendingTransactionAdapter = try self.moneroAdapter.createTransaction(
                        toAddress: address,
                        withPaymentId: paymentId,
                        amountStr: amount?.formatted(),
                        priority: priorityRaw)
                    let moneroPendingTransaction = MoneroPendingTransaction(moneroPendingTransactionAdapter: moneroPendingTransactionAdapter)
                    fulfill(moneroPendingTransaction)
                } catch let error as NSError {
                    if let transactionError = TransactionError(from: error, amount: amount, balance: self.balance) {
                        reject(transactionError)
                    } else {
                        reject(error)
                    }
                }
            }
        }
    }
    
    func startUpdate() {
        updateQueue.async {
            if !self.isUpdateStarted {
                self.status = .startUpdating
            }
            
            self.moneroAdapter.startRefreshAsync()
        }
    }
    
    func observe(_ handler: @escaping ObservableWallet.ChangeHandler) {
        listeners.append(handler)
        handler(.reset, self)
    }
    
    func transactionHistory() -> TransactionHistory {
        if let moneroTransactionHistory = _moneroTransactionHistory {
            moneroTransactionHistory.refresh()
            return moneroTransactionHistory
        }
        
        let moneroTransactionHistory = MoneroTransactionHistory(
            moneroWalletHistoryAdapter: MoneroWalletHistoryAdapter(wallet: moneroAdapter))
        _moneroTransactionHistory = moneroTransactionHistory
        moneroTransactionHistory.refresh()
        return moneroTransactionHistory
    }
    
    func fetchBlockChainHeight(compilation: @escaping (UInt64) -> Void) {
        if _blockchainHeightUpdateDate == nil {
            _blockchainHeight = moneroAdapter.daemonBlockChainHeight()
            
            if _blockchainHeight == 0 {
                _fetchBlockChainHeight() { [weak self] height in
                    self?._blockchainHeight = height
                    self?._blockchainHeightUpdateDate = Date()
                    compilation(height)
                }
            } else {
                _blockchainHeightUpdateDate = Date()
                compilation(_blockchainHeight)
            }
        }
        
        if let date = _blockchainHeightUpdateDate,
            _blockchainHeight == 0 || Date().timeIntervalSince(date) >= 10 {
            _blockchainHeight = moneroAdapter.daemonBlockChainHeight()
        
            if _blockchainHeight == 0 {
                _fetchBlockChainHeight() { [weak self] height in
                    self?._blockchainHeight = height
                    self?._blockchainHeightUpdateDate = Date()
                    compilation(height)
                }
            } else {
                _blockchainHeightUpdateDate = Date()
                compilation(_blockchainHeight)
            }
        } else {
            compilation(_blockchainHeight)
        }
    }
    
    func integratedAddress(for paymentId: String) -> String {
        return self.moneroAdapter.integratedAddress(for: paymentId)
    }
    
    func checkConnection(withTimeout timeout: UInt32) -> Bool {
        return moneroAdapter.checkConnection(withTimeout: timeout)
    }
    
    private func emit(_ change: MoneroWalletChange) {
        listeners.forEach { $0(change, self) }
    }
    
    private func _fetchBlockChainHeight(compilation: @escaping (UInt64) -> Void) {
        guard !_isFetchingBlockChainHeight else {
            return
        }
        
        if let settings = self.settings {
            let urlString = "http://\(settings.uri)/json_rpc"
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let requestBody = [
                "jsonrpc": "2.0",
                "id": "0",
                "method": "getblockcount"
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
               compilation(0)
            }

            let connection = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                do {
                    self?._isFetchingBlockChainHeight = false
                    
                    guard let data = data,
                        error == nil else {
                            compilation(0)
                            return
                    }
                    
                    if
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let result = decoded["result"] as? [String: Any],
                        let height = result["count"] as? UInt64 {
                        compilation(height)
                    } else {
                        compilation(0)
                    }
                } catch {
                    compilation(0)
                }
            }
            _isFetchingBlockChainHeight = true
            connection.resume()
        } else {
            compilation(0)
        }
    }
}

extension MoneroWalletType: MoneroWalletAdapterDelegate {
    func newBlock(_ block: UInt64) {
        if initialCurrentHeight == 0 {
            initialCurrentHeight = block
        }
        self.currentHeight = block
        let newBlock = Block(height: block)
        self.fetchBlockChainHeight() { [weak self] blockchainHeight in
            guard
                let initialCurrentHeight = self?.initialCurrentHeight,
                let status = self?.status else {
                    return
            }
            
            let updatingProgress = NewBlockUpdate(
                block: newBlock,
                initialBlock: Block(height: initialCurrentHeight),
                lastBlock: Block(height: blockchainHeight))
            
            switch status {
            case .notConnected, .failedConnection(_):
                return
            default:
                break
            }
            
            if case .updating = status {} else {
                self?.status = .startUpdating
            }
            
            updateQueue.async {
                self?.status = .updating(updatingProgress)
            }
        }
    }
    
    func refreshed() {
        updateQueue.async {
            self.fetchBlockChainHeight() { blockChainHeight in
                let diff: Int = Int(blockChainHeight) - Int(self.currentHeight)
                self.emit(.changedBalance(self.balance))
                self.emit(.changedUnlockedBalance(self.unlockedBalance))

                switch self.status {
                case .failedConnection(_), .notConnected, .connecting:
                    break
                default:
                    if diff == blockChainHeight {
                        self.currentHeight = blockChainHeight
                        self.status = .updated
                        _ = self.save()
                        return
                    }
                }
                
                switch self.status {
                case .updating(_), .startUpdating:
                    if diff <= moneroBlockSize {
                        self.status = .updated
                        _ = self.save()
                    }
                default:
                    break
                }
            }
        }
    }
    
    func updated() {
        self.emit(.changedBalance(balance))
        self.emit(.changedUnlockedBalance(unlockedBalance))
    }
    
    func moneyReceived(_ txId: String!, amount: UInt64) {
        emit(.changedBalance(balance))
        emit(.changedUnlockedBalance(unlockedBalance))
    }
    
    func moneySpent(_ txId: String!, amount: UInt64) {
        emit(.changedBalance(balance))
        emit(.changedUnlockedBalance(unlockedBalance))
    }
    
    func unconfirmedMoneyReceived(_ txId: String!, amount: UInt64) {
        emit(.changedBalance(balance))
        emit(.changedUnlockedBalance(unlockedBalance))
    }
}
