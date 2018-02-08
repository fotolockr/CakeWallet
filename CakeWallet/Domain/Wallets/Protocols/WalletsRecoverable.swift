//
//  WalletsRecoverable.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsRecoverable {
    func recoveryWallet(withName name: String, seed: String) -> Promise<String>
}
