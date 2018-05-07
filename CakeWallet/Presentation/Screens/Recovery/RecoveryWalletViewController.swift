//
//  RecoveryWalletViewController.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import PromiseKit
import FontAwesome_swift

final class RecoveryViewController: BaseViewController<RecoveryView> {
    
    // MARK: Property injections
    var onPrepareRecovery: (() -> Promise<Void>)?
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
    
    init(wallets: WalletsRecoverable, name: String = "", seed: String = "") {
        self.wallets = wallets
        super.init()
        
        if !seed.isEmpty {
            contentView.seedTextView.text = seed
            contentView.placeholderLabel.isHidden = true
        }
        
        contentView.walletNameTextField.text = name
    }
    
    override func configureBinds() {
        title = "Recover wallet"
        contentView.confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        contentView.restoreFromHeightView.datePicker.addTarget(self, action: #selector(onDateChange(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if
            let isModal = navigationController?.isModal,
            isModal && navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem.init(
                image: UIImage.fontAwesomeIcon(name: .close, textColor: .black, size: CGSize(width: 24, height: 24)),
                style: .plain,
                target: self,
                action: #selector(close))
            navigationItem.leftBarButtonItem = closeButton
        }
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
        
        (onPrepareRecovery?() ?? Promise(value: ()))
            .then { [weak self] _ -> Promise<String> in
                guard let this = self else {
                    return Promise(value: "")
                }
                
                return this.wallets.recoveryWallet(withName: this.name, seed: this.seed, restoreHeight: this.restoreHeight)
            }.then { [weak self ] _ in
                self?.alert?.dismiss(animated: false) {
                    self?.onRecovered?()
                }
            }.catch { [weak self]  error in
                self?.alert?.dismiss(animated: false) {
                    self?.showError(error)
                }
        }
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    private func isValidForm() -> Bool {
        return !name.isEmpty && !seed.isEmpty
    }
}
