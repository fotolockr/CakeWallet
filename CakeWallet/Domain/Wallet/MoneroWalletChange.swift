//
//  MoneroWalletChange.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

enum MoneroWalletChange {
    case reset
    case changedBalance(Amount)
    case changedUnlockedBalance(Amount)
    case changedAddress(String)
    case changedStatus(NetworkStatus)
    case changedEstimatedFee(Amount)
    case changedIsNew(Bool)
}
