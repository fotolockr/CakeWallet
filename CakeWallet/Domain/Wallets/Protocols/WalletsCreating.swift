//
//  WalletsCreating.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol WalletsCreating {
    func create(withName name: String) -> Promise<String>
    func isExistWallet(withName name: String) -> Promise<Bool>
}
