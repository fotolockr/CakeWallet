//
//  KeychainStorage.swift
//  Wallet
//
//  Created by Cake Technologies 11/21/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation
import SwiftKeychainWrapper

protocol KeychainStorage {
    func set(value: String, forKey key: KeychainKey) throws
    func fetch(forKey key: KeychainKey) throws -> String
    func remove(forKey key: KeychainKey) throws
}
