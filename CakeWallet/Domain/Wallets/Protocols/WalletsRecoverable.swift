//
//  WalletsRecoverable.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsRecoverable {
    func recoveryWallet(withName name: String, seed: String) -> Promise<String>
}
