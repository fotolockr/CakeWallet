//
//  Proxable.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation

protocol Proxable {
    associatedtype Origin
    
    var origin: Origin { get }
    
    func `switch`(origin: Origin)
}
