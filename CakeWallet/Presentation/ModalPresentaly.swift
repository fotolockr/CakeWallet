//
//  ModalPresentaly.swift
//  CakeWallet
//
//  Created by Cake Technologies on 02.03.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

protocol ModalPresentaly {
    func presentModal(_ viewController: UIViewController)
}

extension ModalPresentaly where Self: UIViewController & UIViewControllerTransitioningDelegate {
    func presentModal(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        
        self.present(viewController, animated: true)
    }
}
