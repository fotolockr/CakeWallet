//
//  UITabBarController+viewControllersInit.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

extension UITabBarController {
    convenience init(viewControllers: [UIViewController]) {
        self.init()
        self.setViewControllers(viewControllers, animated: false)
    }
}
