//
//  WalletsSeedFetchable.swift
//  Wallet
//
//  Created by Cake Technologies 12/4/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsSeedFetchable {
    func fetchSeed(for walletIndex: WalletIndex) -> Promise<String>
}
