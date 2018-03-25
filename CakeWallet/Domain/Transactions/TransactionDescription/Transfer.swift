//
//  Transfer.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

protocol Transfer {
    var amount: Amount { get }
    var address: String { get }
}
