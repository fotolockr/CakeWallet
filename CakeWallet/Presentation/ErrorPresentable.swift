//
//  ErrorPresentable.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

protocol ErrorPresentable {
    func showError(_ error: Error, withTitle title: String?)
}

extension UIViewController: ErrorPresentable {
    func showError(_ error: Error, withTitle title: String? = nil) {
        UIAlertController.showError(
            title: title,
            message: error.localizedDescription,
            presentOn: self)
    }
}
