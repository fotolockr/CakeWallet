//
//  ErrorPresentable.swift
//  CakeWallet
//
//  Created by FotoLockr on 31.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
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
