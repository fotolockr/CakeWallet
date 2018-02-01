//
//  WalletsLoadable.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsLoadable {
    func loadWallet(withName name: String) -> Promise<Void>
}
