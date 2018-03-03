//
//  WalletsLoadable.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsLoadable {
    func loadWallet(withName name: String) -> Promise<Void>
}
