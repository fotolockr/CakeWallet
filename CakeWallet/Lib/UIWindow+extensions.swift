//
//  UIWindow+extensions.swift
//  Wallet
//
//  Created by FotoLockr on 16.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

extension UIWindow {
    func changeRoot(viewController: UIViewController) {
        self.rootViewController = viewController
//        UIView.transition(with: self, duration: 0.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//            self.rootViewController = viewController
//        }, completion: nil)
    }
    
    func popucate(view: UIView) {
//        let titleView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.width, height: 50)))
        
        
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:  CGSize(width: self.frame.width, height: 50))
        view.sizeToFit()
        view.needsUpdateConstraints()
//        titleView.backgroundColor = .red
//        titleView.addSubview(view)
//        titleView.bringSubview(toFront: view)

        if let vc = rootViewController as? UITabBarController,
            let nav = vc.selectedViewController as? UINavigationController {
            nav.viewControllers.last?.navigationItem.titleView = view
        } else {
            rootViewController?.navigationItem.titleView = view
        }
    }
}
