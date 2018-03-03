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
    private var restoreHeight: UInt64 {
        let heightStr = contentView.restoreFromHeightView.restoreHeightTextField.text ?? ""
        return UInt64(heightStr) ?? 0
    }
    
    init(wallets: WalletsRecoverable) {
        self.wallets = wallets
        super.init()
    }
    
    override func configureBinds() {
        title = "Recover wallet"
        contentView.confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        contentView.restoreFromHeightView.datePicker.addTarget(self, action: #selector(onDateChange(_:)), for: .valueChanged)
    }
    
    @objc
    private func onDateChange(_ datePicker: UIDatePicker) {
        let date = datePicker.date
        
        getHeight(from: date)
            .then { [weak self] height -> Void in
                guard height != 0 else {
                    return
                }
                
                self?.contentView.restoreFromHeightView.restoreHeightTextField.text = "\(height)"
            }.catch { error in
                print(error)
        }
    }
    
    @objc
    private func confirm() {
        guard isValidForm() else {
            return
        }
        
        let _alert = UIAlertController.showSpinner(message: "Recovering wallet")
        alert = _alert
        present(_alert, animated: true)
        
        wallets.recoveryWallet(withName: name, seed: seed, restoreHeight: restoreHeight)
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
