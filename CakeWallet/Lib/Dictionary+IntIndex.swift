//
//  Dictionary+IntIndex.swift
//  Wallet
//
//  Created by FotoLockr on 09.11.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)]
        }
    }
}
