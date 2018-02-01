//
//  UITableViewCell+identifier.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}
