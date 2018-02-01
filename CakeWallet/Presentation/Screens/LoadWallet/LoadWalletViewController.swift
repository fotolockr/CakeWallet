//
//  LoadWalletViewController.swift
//  Wallet
//
//  Created by FotoLockr on 11/23/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class LoadWalletViewController: BaseViewController<BaseView> {
    
    // MARK: Property injections
    
    var onLogined: VoidEmptyHandler
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
        verifyPasswordViewController.onVerified = {
            let alert = UIAlertController.showSpinner(message: "Loading wallet - \(self.walletName)")
            self.present(alert, animated: true)
            
            self.wallets.loadWallet(withName: self.walletName)
                .then { [weak self] in
                    alert.dismiss(animated: true) {
                        self?.onLogined?()
                    }
                }.catch { [weak self] error in
                    alert.dismiss(animated: true) {
                        self?.showError(error)
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
}

extension LoadWalletViewController: PresentableAccessView {
    var canBePresented: Bool {
        return verifyPasswordViewController.canBePresented
    }
    
    func callback() {
        verifyPasswordViewController.onVerified?()
    }
}

