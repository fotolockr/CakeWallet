//
//  NewwalletViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

private let maxLengthWalletName = 32

final class NewWalletViewController: BaseViewController<NewWalletView>, UITextFieldDelegate {
    
    // MARK: Property injections
    
    var onWalletCreated: ((String, String) -> Void)?
    
    private let wallets: WalletsCreating
    private var name: String {
        return contentView.walletNameTextField.text ?? ""
    }
    private weak var alert: UIAlertController?
    
    init(wallets: WalletsCreating) {
        self.wallets = wallets
        super.init()
        title = "New wallet"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.walletNameTextField.becomeFirstResponder()
        
        if isModal {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    override func configureBinds() {
        contentView.walletNameTextField.delegate = self
        contentView.nextButton.addTarget(self, action: #selector(startCreatingWallet), for: .touchUpInside)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= maxLengthWalletName
    }
    
    @objc
    private func startCreatingWallet() {
        guard !name.isEmpty else {
            return
        }
        
        let _alert = UIAlertController.showSpinner(message: "Creating wallet")
        alert = _alert
        present(_alert, animated: true)
        
        wallets.isExistWallet(withName: name)
            .then { [weak self] isExist -> Void in
                guard !isExist else {
                    self?.alert?.dismiss(animated: false) {
                        if let this = self {
                            UIAlertController.showError(
                                title: "Create wallet",
                                message: "Wallet with name - \(this.name) is already exist.",
                                presentOn: this)
                        }
                    }
                    
                    return
                }
                
                self?.createWallet()
            }.catch { [weak self] error in
                self?.alert?.dismiss(animated: true) {
                    self?.showError(error)
                }
        }
    }
    
    @objc
    private func close() {
        self.dismiss(animated: true)
    }
    
    private func createWallet() {
        wallets.create(withName: name)
            .then { [weak self] seed -> Void in
                self?.alert?.dismiss(animated: true) {
                    if let name = self?.name {
                        self?.onWalletCreated?(seed, name)
                    }
                }
            }.catch { [weak self] error in
                self?.alert?.dismiss(animated: true) {
                    self?.showError(error)
                }
        }
    }
}
