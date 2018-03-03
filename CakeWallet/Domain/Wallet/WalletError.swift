//
//  WalletError.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

enum WalletError: Error {
    case incorrectPassword
    case fetchingBlockchainHeight(String)
    case cannotFindWalletPassword(String)
    case walletIsExist(String)
}

extension WalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .cannotFindWalletPassword(walletName):
            return NSLocalizedString("Cannot find password for wallet - \(walletName).", comment: "")
        case .incorrectPassword:
            return NSLocalizedString("Incorrect password.", comment: "")
        case .fetchingBlockchainHeight(let reason):
            return NSLocalizedString(reason, comment: "")
        case let .walletIsExist(name):
            return NSLocalizedString("Wallet with name - \(name) is already exist", comment: "")
        }
    }
}
