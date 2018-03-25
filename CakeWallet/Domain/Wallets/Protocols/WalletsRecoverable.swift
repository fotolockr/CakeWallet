//
//  WalletsRecoverable.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol WalletsRecoverable {
    func recoveryWallet(withName name: String, seed: String, restoreHeight: UInt64) -> Promise<String>
    func recoveryWallet(withName name: String, publicKey: String, viewKey: String, spendKey: String, restoreHeight: UInt64) -> Promise<String>
}

extension WalletsRecoverable {
    func recoveryWallet(withName name: String, seed: String) -> Promise<String> {
        return recoveryWallet(withName: name, seed: seed, restoreHeight: 0)
    }
    
    func recoveryWallet(withName name: String, publicKey: String, viewKey: String, spendKey: String) -> Promise<String> {
        return recoveryWallet(withName: name, publicKey: publicKey, viewKey: viewKey, spendKey: spendKey, restoreHeight: 0)
    }
}
