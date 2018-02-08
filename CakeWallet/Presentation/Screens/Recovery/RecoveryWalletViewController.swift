//
//  RecoveryWalletViewController.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class RecoveryViewController: BaseViewController<RecoveryView> {
    
    // MARK: Property injections
    
    var onRecovered: VoidEmptyHandler
    
    private let wallets: WalletsRecoverable
    private var name: String {
        return contentView.walletNameTextField.text ?? ""
    }
    private var seed: String {
        return contentView.seedTextView.text
    }
    private weak var alert: UIAlertController?
    
    init(wallets: WalletsRecoverable) {
        self.wallets = wallets
        super.init()
    }

    override func configureBinds() {
        title = "Recover wallet"
        contentView.confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    @objc
    private func confirm() {
        guard isValidForm() else {
            return
        }
        
        let _alert = UIAlertController.showSpinner(message: "Recovery account")
        alert = _alert
        present(_alert, animated: true)
        
        wallets.recoveryWallet(withName: name, seed: seed)
            .then { [weak self ] _ in
                self?.alert?.dismiss(animated: false) {
                    self?.onRecovered?()
                }
            }.catch { [weak self]  error in
                self?.alert?.dismiss(animated: false) {
                    self?.showError(error)
                }
        }
    }
    
    private func isValidForm() -> Bool {
        return !name.isEmpty && !seed.isEmpty
    }
}
