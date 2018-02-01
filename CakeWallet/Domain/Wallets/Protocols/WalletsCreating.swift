//
//  WalletsCreating.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol WalletsCreating {
    func create(withName name: String) -> Promise<String>
    func isExistWallet(withName name: String) -> Promise<Bool>
}
