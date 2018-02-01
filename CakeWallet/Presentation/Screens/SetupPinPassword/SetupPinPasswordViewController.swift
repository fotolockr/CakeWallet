//
//  SetupPinPasswordViewController.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class SetupPinPasswordViewController: BaseViewController<BaseView> {
    var setuped: VoidEmptyHandler
    
    private let account: Account
    private let pinPasswordViewController: PinPasswordViewController
    private var password: String
    
    init(account: Account, pinPasswordViewController: PinPasswordViewController) {
        self.account = account
        self.pinPasswordViewController = pinPasswordViewController
        password = ""
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    override func configureBinds() {
        title = "Setup Pin"
        pinPasswordViewController.pin { [weak self] pinPassword in
            guard let this = self else { return }
            
            if this.password.isEmpty {
                this.password = pinPassword
                this.prepareRepeatingPinPassword()
                return
            }
            
            guard this.password == pinPassword else {
                // FIX-ME: SHOW ALERT!
                print("Incorrect pin")
                return
            }
            
            this.account.setup(newPassword: pinPassword)
                .then { this.showSuccessAlert() }
                .catch { error in this.showError(error) }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: nil, message: "Pin password set up successfully", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
            self.reset()
            self.setuped?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func reset() {
        pinPasswordViewController.descriptionText = "Enter your pin"
        pinPasswordViewController.empty()
        password = ""
    }
    
    private func setView() {
        view.addSubview(pinPasswordViewController.view)
        
        pinPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func prepareRepeatingPinPassword() {
        pinPasswordViewController.descriptionText = "Repeat your pin"
        pinPasswordViewController.empty()
    }
}
