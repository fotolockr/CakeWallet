//
//  DonationViewController.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 20.02.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import UIKit
import QRCode

final class DonationViewController: BaseViewController<DonationView> {
    
    // MARK: Property injections
    
    var presentSendScreen: VoidEmptyHandler
    private let address: String
    
    required init(address: String = Configurations.donactionAddress) {
        self.address = address
        super.init()
    }
    
    override func configureBinds() {
        title = "Support us"
        setAddress(address)
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    private func setAddress(_ address: String) {
        let uri = "monero:\(address)"
        let qrCode = QRCode(uri)
        contentView.qrImageView.image = qrCode?.image
        contentView.addressLabel.text = address
    }
    
    @objc
    private func showMenu() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = self.address
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            let activityViewController = UIActivityViewController(
                activityItems: [self.address],
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
