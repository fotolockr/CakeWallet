//
//  ReceiveViewController.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit
import QRCode
import FontAwesome_swift
import MessageUI

enum MessageUIEmailError: Error {
    case emailUnavailable
    case textMessageUnavailable
}

extension MessageUIEmailError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emailUnavailable:
            return "Sending email is not configured on this device"
        case .textMessageUnavailable:
            return "Sending text message is not configured on this device"
        }
    }
}

final class ReceiveViewController: BaseViewController<ReceiveView>, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    // MARK: Property injections
    
    private let address: String
    private weak var textMessageContainerVC: UIViewController?
    
    convenience init(wallet: WalletProtocol) {
        self.init(address: wallet.address)
    }
    
    init(address: String) {
        self.address = address
        super.init()
    }
    
    override func configureBinds() {
        title = "Receive"
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        self.navigationItem.rightBarButtonItem = shareButton
        setAddress()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            self.textMessageContainerVC?.dismiss(animated: false)
        }
    }
    
    private func setAddress() {
        contentView.addressLabel.text = address
        contentView.qrImageView.image = QRCode(address)?.image
    }
    
    private func sendText(message: String) {
        guard MFMessageComposeViewController.canSendText() else {
            showError(MessageUIEmailError.textMessageUnavailable)
            return
        }
        
        let composeVC = MFMessageComposeViewController()
        composeVC.body = message
        composeVC.recipients = []
        composeVC.messageComposeDelegate = self
        
        let _textMessageContainerVC = UIViewController()
        _textMessageContainerVC.modalPresentationStyle = .overFullScreen
        textMessageContainerVC = _textMessageContainerVC
        
        present(_textMessageContainerVC, animated: false) {
            _textMessageContainerVC.present(composeVC, animated: true)
        }
    }
    
    private func sendEmail(subject: String = "My XMR address", text: String) {
        guard MFMailComposeViewController.canSendMail() else {
            showError(MessageUIEmailError.emailUnavailable)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([])
        composeVC.setSubject(subject)
        composeVC.setMessageBody(text, isHTML: false)
        composeVC.modalPresentationStyle = .overFullScreen
        
        present(composeVC, animated: true)
    }
    
    @objc
    private func showMenu() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            UIPasteboard.general.string = self?.address
        }
        
        let sendEmailAction = UIAlertAction(title: "Send email", style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.sendEmail(text: this.address)
        }
        let sendTextMessageAction = UIAlertAction(title: "Send text message", style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.sendText(message: this.address)
        }
        
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.addAction(copyAction)
        alertViewController.addAction(sendEmailAction)
        alertViewController.addAction(sendTextMessageAction)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true)
    }
}
