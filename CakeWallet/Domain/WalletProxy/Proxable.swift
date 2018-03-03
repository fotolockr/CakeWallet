//
//  Proxable.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

protocol Proxable {
    associatedtype Origin
    
    var origin: Origin { get }
    
    func `switch`(origin: Origin)
}
