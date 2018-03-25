//
//  EmptyWallet.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import PromiseKit

final class EmptyWallet: WalletProtocol {
    let isConnected = false
    let name = "Unnamed wallet"
    let balance: Amount = MoneroAmount(value: 0)
    let unlockedBalance: Amount = MoneroAmount(value: 0)
    let address = "No address"
    let currentHeight: UInt64 = 0
    let seed = "No seed"
    var status: NetworkStatus = .notConnected
    let isReadyToReceive = false
    let isWatchOnly = true
    var viewKey: WalletKey {
        return WalletKey(pub: "", sec: "")
    }
    var spendKey: WalletKey {
        return WalletKey(pub: "", sec: "")
    }
    
    func save() -> Promise<Void> {
        // FIX-ME: Not implemented
        
        return Promise { _, _ in
            
        }
    }
    
    func connect(withSettings settings: ConnectionSettings, updateState: Bool) -> Promise<Void> {
        // FIX-ME: Not implemented
        
        return Promise { _, _ in
            
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void> {
        // FIX-ME: Not implemented
        
        return Promise { _, _ in
            
        }
    }
    
    func close() {
        // FIX-ME: Not implemented
    }
    
    func createTransaction(to address: String, withPaymentId paymentId: String, amount: Amount?, priority: TransactionPriority) -> Promise<PendingTransaction> {
        // FIX-ME: Not implemented
        
        return Promise { _, _ in
            
        }
    }
    
    func startUpdate() {
        // FIX-ME: Not implemented
    }
    
    func observe(_ handler: @escaping ObservableWallet.ChangeHandler) {
        // FIX-ME: Not implemented
    }
    
    func transactionHistory() -> TransactionHistory {
        // FIX-ME: Not implemented
        return EmptyTransactionHistory()
    }
    
    func integratedAddress(for paymentId: String) -> String {
        return ""
    }
    
    func clear() {
        // FIX-ME: Not implemented
    }
}
