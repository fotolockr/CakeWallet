//
//  Roundable+UIView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

extension Roundable where Self: UIView {
    func rounded() {
        let height = self.frame.size.height
        self.layer.cornerRadius = height / 2
    }
}

extension UIButton: Roundable {}
extension UIImageView: Roundable {}
