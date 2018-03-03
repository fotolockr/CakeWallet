//
//  HalfSizePresentationController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 02.03.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class HalfSizePresentationController: UIPresentationController {
    static var offsetMultiplier: CGFloat {
        // FIX-ME: HARDCODE
        
        let height = UIScreen.main.bounds.height
        return height <= 568 ? 0 : 0.4
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: containerView!.bounds.width,
                height: containerView!.bounds.height))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let height = containerView!.bounds.height * (1.0 - type(of: self).offsetMultiplier)
        let x: CGFloat = 0
        let y = containerView!.bounds.height * type(of: self).offsetMultiplier
        
        return CGRect(
            x: x,
            y: y,
            width: containerView!.bounds.width,
            height: height)
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            backgroundView.alpha = 0
            containerView.addSubview(backgroundView)
            
            if
                let nav = presentedViewController as? UINavigationController,
                let vc = nav.viewControllers.last {
                backgroundView.addSubview(vc.view)
            } else {
                backgroundView.addSubview(presentedViewController.view)
            }
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.backgroundView.alpha = 1
            })
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.backgroundView.alpha = 0
            })
        }
    }
//    
//    override func dismissalTransitionDidEnd(_ completed: Bool) {
//        guard completed else {
//            return
//        }
//        
//        backgroundView.removeFromSuperview()
//    }
    
    @objc
    func hide() {
        if let nav = presentedViewController as? UINavigationController {
            nav.viewControllers.last?.dismiss(animated: true) {
                nav.viewControllers = []
            }
        } else {
            presentedViewController.dismiss(animated: true)
        }
    }
}
