//
//  KeychainStorageError.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

enum KeychainStorageError: Error {
    case cannotSetValue(String)
    case cannotFindValue(String)
    case cannotRemoveValue(String)
}
