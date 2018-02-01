//
//  KeychainStorage.swift
//  Wallet
//
//  Created by FotoLockr on 11/21/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

protocol KeychainStorage {
    func set(value: String, forKey key: KeychainKey) throws
    func fetch(forKey key: KeychainKey) throws -> String
    func remove(forKey key: KeychainKey) throws
}
