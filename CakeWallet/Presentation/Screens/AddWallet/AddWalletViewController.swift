//
//  SignInViewController.swift
//  Wallet
//
//  Created by Cake Technologies 25.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class AddWalletViewController: BaseViewController<AddWalletView> {
    
    // MARK: Property injections
    
    var presentCreateNewWallet: VoidEmptyHandler
    var presentRecoveryWallet: VoidEmptyHandler
    
    override init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
    }
    
    override func configureBinds() {
        title = "Sign up/Sign in"
        contentView.newWalletButton.addTarget(self, action: #selector(createNewWallet), for: .touchUpInside)
        contentView.recoveryWalletButton.addTarget(self, action: #selector(recoveryNewWallet), for: .touchUpInside)
        
        // FIX-ME: Unnamed constant
        
        contentView.recoveryDescriptionLabel.text = "Monero wallet recovery is a slow process.\nThe recovery does not work in the background."
    }
   
    @objc
    private func close() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    private func createNewWallet() {
        presentCreateNewWallet?()
    }
    
    @objc
    private func recoveryNewWallet() {
        presentRecoveryWallet?()
    }
}
