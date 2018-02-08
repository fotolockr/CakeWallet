//
//  WelcomeViewController.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class WelcomeViewController: BaseViewController<WelcomeView> {
    
    // MARK: Property injections
    
    var start: VoidEmptyHandler
    
    override init() {
        start = nil
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func configureBinds() {
        contentView.startButton.addTarget(self, action: #selector(onStart), for: .touchUpInside)
        
        // FIX-ME: Unnamed constant
        
        contentView.welcomeLabel.text = "Welcome"
        
        if let appName = Bundle.main.displayName {
            
            // FIX-ME: Unnamed constant
            
            contentView.welcomeSubtitleLabel.text = "to \(appName),\nthe first iOS wallet for Monero."
        }
        
        // FIX-ME: Unnamed constant
        
        contentView.descriptionTextView.text = "On the next screen you’ll be able to recover a wallet using your seed or create a new wallet.\n\nPlease enjoy this wallet! We would love your feedback."
    }
    
    @objc
    private func onStart() {
        start?()
    }
}
