//
//  ChangePasswordViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/17/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class ChangePasswordViewController: BaseViewController<BaseView> {
    
    // MARK: Property injections
    
    var onPasswordChanged: VoidEmptyHandler
    private let pinPasswordViewController: PinPasswordViewController
    private let account: Account
    private var oldPassword: String
    
    init(account: Account, pinPasswordViewController: PinPasswordViewController) {
        self.account = account
        self.pinPasswordViewController = pinPasswordViewController
        oldPassword = ""
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinPasswordViewController.descriptionText = "Enter your password"
        pinPasswordViewController.onCloseHandler = { [weak self] in self?.dismiss(animated: true) }
        pinPasswordViewController.pin { [weak self] pinPassword in
            guard let oldPassword = self?.oldPassword else {
                return
            }
            
            if oldPassword.isEmpty {
                self?.oldPassword = pinPassword
                self?.pinPasswordViewController.empty()
                self?.pinPasswordViewController.descriptionText = "Enter your new password"
                return
            }
            
            
            self?.account.change(password: pinPassword, oldPassword: oldPassword)
                .then(on: DispatchQueue.main) { _ -> Void in
                    self?.reset()
                    self?.onPasswordChanged?()
                }.catch(on: DispatchQueue.main) { error in
                    self?.reset()
                    self?.showError(error)
            }
        }
        
        view.addSubview(pinPasswordViewController.view)
        
        pinPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func reset() {
        pinPasswordViewController.empty()
        pinPasswordViewController.descriptionText = "Enter your password"
        oldPassword = ""
    }
}

