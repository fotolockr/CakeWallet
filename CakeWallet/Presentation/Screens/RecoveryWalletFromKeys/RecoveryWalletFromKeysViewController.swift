//
//  RecoveryWalletFromKeysViewController.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 14.02.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import UIKit

final class RecoveryWalletFromKeysViewController: BaseViewController<RecoveryWalletFromKeysView> {
    
    // MARK: Property injections
    
    var onRecovered: VoidEmptyHandler
    
    private let wallets: WalletsRecoverable
    private var name: String {
        return contentView.nameTextField.text ?? ""
    }
    private var publicKey: String {
        return contentView.publicKeyTextField.text ?? ""
    }
    private var viewKey: String {
        return contentView.viewKeyTextField.text ?? ""
    }
    private var spendKey: String {
        return contentView.spendKeyTextField.text ?? ""
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
        contentView.watchOnlyDescriptionLabel.text = "* Leave this blank for a watch only wallet."
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
        
        wallets.recoveryWallet(withName: name, publicKey: publicKey, viewKey: viewKey, spendKey: spendKey, restoreHeight: restoreHeight)
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
        return !name.isEmpty && !publicKey.isEmpty && !viewKey.isEmpty
    }
}
