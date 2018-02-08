//
//  UIViewController+isModal.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

extension UIViewController {
    var isModal: Bool {
        if let navigationController = self.navigationController {
            if navigationController.isModal {
                return true
            }
            
            if navigationController.viewControllers.first != self {
                return false
            }
        }
        
        if self.presentingViewController != nil {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}
