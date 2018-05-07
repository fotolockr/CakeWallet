//
//  LoadWalletViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/23/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class LoadWalletViewController: BaseViewController<BaseView> {
    
    // MARK: Property injections
    
    var onLogined: VoidEmptyHandler
    var onShowWalletsScreen: VoidEmptyHandler
    var onRecoveryWallet: ((String) -> Void)?
    private let walletName: String
    private let wallets: WalletsLoadable
    private let verifyPasswordViewController: VerifyPinPasswordViewController
    
    init(walletName: String, wallets: WalletsLoadable, verifyPasswordViewController: VerifyPinPasswordViewController) {
        self.walletName = walletName
        self.wallets = wallets
        self.verifyPasswordViewController = verifyPasswordViewController
        super.init()
        configureView()
    }
    
    override func configureBinds() {
        verifyPasswordViewController.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        verifyPasswordViewController.onVerified = {
            let alert = UIAlertController.showSpinner(message: "Loading wallet - \(self.walletName)")
            self.present(alert, animated: true)
            
            self.wallets.loadWallet(withName: self.walletName)
                .then { [weak self] in
                    alert.dismiss(animated: true) {
                        self?.onLogined?()
                    }
                }.catch { [weak self] error in
                    print("error \(error)")
                    
                    alert.dismiss(animated: true) {
                        if let error = error as? AuthenticationError {
                            self?.showError(error)
                            return
                        }
                        
                        if error.localizedDescription == "std::bad_alloc" {
                            self?.recoveryWalletWithError()
                        } else {
                            self?.showWalletsList()
                        }
                    }
                }
        }
    }
    
    private func configureView() {
        view.addSubview(verifyPasswordViewController.view)
        verifyPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func recoveryWalletWithError() {
        let alert = UIAlertController(title: nil, message: "We are having trouble loading your wallet file as it may be damaged.  We can try to recover your wallet or you can open/add another wallet.", preferredStyle: .alert)
        let recoveryAction = UIAlertAction(title: "Yes, try to recover this wallet", style: .default) { _ in
            self.onRecoveryWallet?(self.walletName)
        }
        let walletsAction = UIAlertAction(title: "I will open/add another wallet", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(recoveryAction)
        alert.addAction(walletsAction)
        present(alert, animated: true)
    }
    
    private func showWalletsList() {
        let alert = UIAlertController(title: nil, message: "We had some trouble loading your wallet. Please try to recover it using your seed in the setting screen.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension LoadWalletViewController: PresentableAccessView {
    var canBePresented: Bool {
        return verifyPasswordViewController.canBePresented
    }
    
    func callback() {
        verifyPasswordViewController.onVerified?()
    }
}

