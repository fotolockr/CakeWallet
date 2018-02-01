//
//  MnemoticViewController.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class SeedViewController: BaseViewController<SeedView> {
    
    // MARK: Property injections
    
    var finishHandler: VoidEmptyHandler
    private var walletIndex: WalletIndex?
    private let seed: String
    
    init(seed: String) {
        self.seed = seed
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func configureBinds() {
        title = "Seed"
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        navigationItem.rightBarButtonItem = shareButton
        contentView.seedTextView.text = seed
        
        if isModal {
            let closeButton = UIBarButtonItem(
                image: UIImage.fontAwesomeIcon(name: .close, textColor: .gray, size: CGSize(width: 36, height: 36)),
                style: .done,
                target: self, action: #selector(close))
            contentView.finishButton.isHidden = true
            navigationItem.leftBarButtonItem = closeButton
        } else {
            contentView.finishButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        }
    }
    
    @objc
    private func close() {
        finishHandler?()
    }
    
    // FIX-ME: Refactor me please...
    
    @objc
    private func showMenu() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = self.seed
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            let activityViewController = UIActivityViewController(
                activityItems: [self.seed],
                applicationActivities: nil)
            activityViewController.excludedActivityTypes = [
                UIActivityType.message, UIActivityType.mail,
                UIActivityType.print, UIActivityType.copyToPasteboard]
            self.present(activityViewController, animated: true)
        }
        
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.addAction(copyAction)
        alertViewController.addAction(shareAction)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true)
    }
}
