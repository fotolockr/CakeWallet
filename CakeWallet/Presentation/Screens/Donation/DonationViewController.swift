//
//  DonationViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 20.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import QRCode

final class DonationViewController: BaseViewController<DonationView>, UIViewControllerTransitioningDelegate, ModalPresentaly {
    
    // MARK: Property injections
    
    var presentSendScreen: VoidEmptyHandler
    private let address: String
    private let canSend: Bool
    
    required init(address: String = Configurations.donactionAddress, canSend: Bool) {
        self.address = address
        self.canSend = canSend
        super.init()
    }
    
    override func configureBinds() {
        title = "Support us"
        setAddress(address)
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        navigationItem.rightBarButtonItem = shareButton
        contentView.submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        
        if !canSend {
            contentView.amountTextField.isHidden = true
            contentView.submitButton.isHidden = true
        }
        
        contentView.descriptionAddress.text = "Cake Wallet is a completely free and open-source application. We do not charge for the app nor do we charge fees for transactions. Please donate to support the ongoing development."
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = contentView.safeHeight() > 500 ? contentView.safeHeight() : 500
        contentView.scrollView.contentSize = CGSize(width: contentView.frame.width, height: height)
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
    
    @objc
    private func onSubmit() {
        presentShowSendScreen(withAdress: address, amount: amount())
    }
    
    private func amount() -> Amount {
        if let amountStr = contentView.amountTextField.text {
            return MoneroAmount(amount: amountStr.replacingOccurrences(of: ",", with: "."))
        } else {
            return MoneroAmount(value: 0)
        }
    }
    
    private func presentShowSendScreen(withAdress adress: String, amount: Amount) {
        guard canSend else {
            let _ = UIAlertController.showInfo(
                message: "You cannot send from a watch only wallet.",
                presentOn: self)
            return
        }
        
        let sendViewController = try! container.resolve(arguments: address, amount) as SendViewController
        presentModal(sendViewController)
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let nav = UINavigationController(rootViewController: presented)
        let halfSizePresentationController = HalfSizePresentationController(presentedViewController: nav, presenting: presenting)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: halfSizePresentationController, action: #selector(halfSizePresentationController.hide))
        nav.topViewController?.navigationItem.leftBarButtonItem = doneButton
        return halfSizePresentationController
    }
}
