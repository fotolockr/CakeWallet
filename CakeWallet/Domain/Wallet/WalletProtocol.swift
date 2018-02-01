//
//  WalletProtocol.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol ObservableWallet {
    typealias ChangeHandler = (MoneroWalletChange, WalletProtocol) -> Void
    
    func observe(_ handler: @escaping ChangeHandler)
}

protocol WalletProtocol: ObservableWallet, TransactionCreatableProtocol {
    var name: String { get }
    var balance: Amount { get }
    var unlockedBalance: Amount { get }
    var address: String { get }
    var currentHeight: UInt64 { get }
    var seed: String { get }
    var status: NetworkStatus { get set }
    var isConnected: Bool { get }
    var isReadyToReceive: Bool { get }
    
    func save() -> Promise<Void>
    func connect(withSettings settings: ConnectionSettings, updateState: Bool) -> Promise<Void>
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void>
    func close()
    func startUpdate()
    func transactionHistory() -> TransactionHistory
}

extension WalletProtocol {
    func connect(withSettings settings: ConnectionSettings) -> Promise<Void> {
        return connect(withSettings: settings, updateState: true)
    }
}
