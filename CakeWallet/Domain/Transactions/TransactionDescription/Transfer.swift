//
//  Transfer.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

protocol Transfer {
    var amount: Amount { get }
    var address: String { get }
}
