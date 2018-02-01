//
//  MoneroWalletChange.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
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
