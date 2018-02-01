//
//  WalletsSeedFetchable.swift
//  Wallet
//
//  Created by FotoLockr on 12/4/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsSeedFetchable {
    func fetchSeed(for walletIndex: WalletIndex) -> Promise<String>
}
