//
//  ConnectionSettings+doDictionary.swift
//  CakeWallet
//
//  Created by Cake Technologies on 07.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

extension ConnectionSettings {
    func toDictionary() -> [String: Any] {
        var dir = [String: Any]()
        
        if !login.isEmpty {
            dir["login"] = login
        }
        
        if !password.isEmpty {
            dir["password"] = password
        }
        
        dir["uri"] = uri
        return dir
    }
}
