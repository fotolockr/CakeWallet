//
//  WalletProtocol.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol ObservableWallet {
    typealias ChangeHandler = (MoneroWalletChange, WalletProtocol) -> Void
    
    func observe(_ handler: @escaping ChangeHandler)
}

protocol WalletKeysPresent {
    var viewKey: WalletKey { get }
    var spendKey: WalletKey { get }
}

protocol WalletProtocol: ObservableWallet, TransactionCreatableProtocol, WalletKeysPresent {
    var name: String { get }
    var balance: Amount { get }
    var unlockedBalance: Amount { get }
    var address: String { get }
    var currentHeight: UInt64 { get }
    var seed: String { get }
    var status: NetworkStatus { get set }
    var isConnected: Bool { get }
    var isReadyToReceive: Bool { get }
    var isWatchOnly: Bool { get }
    
    func save() -> Promise<Void>
    func connect(withSettings settings: ConnectionSettings, updateState: Bool) -> Promise<Void>
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void>
    func clear()
    func close()
    func startUpdate()
    func transactionHistory() -> TransactionHistory
    func integratedAddress(for paymentId: String) -> String
}

extension WalletProtocol {
    func connect(withSettings settings: ConnectionSettings) -> Promise<Void> {
        return connect(withSettings: settings, updateState: true)
    }
}
