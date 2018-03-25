//
//  PasswordKeyboardKey.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

enum PasswordKeyboardKey {
    case number(Int)
    case delete
    
    init?(from str: String) {
        let str = str.lowercased()
        
        if let i = Int(str),
            i >= 0 && i < 10 {
            self = .number(i)
            return
        }
        
        if str == "delete" || str == "del" {
            self = .delete
            return
        }
        
        return nil
    }
}
