//
//  WalletsRemovable.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsRemovable {
    func removeWallet(withIndex: WalletIndex) -> Promise<Void>
}
