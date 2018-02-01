//
//  Amount.swift
//  Wallet
//
//  Created by FotoLockr on 11/26/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

protocol Amount {
    var value: UInt64 { get }
    func formatted() -> String
}

