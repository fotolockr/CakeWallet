//
//  ReceiveViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
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
    
    private let wallet: WalletProtocol
    private var paymentId: String?
    private var amount: Amount?
    private weak var textMessageContainerVC: UIViewController?
    
    init(wallet: WalletProtocol) {
        self.wallet = wallet
        super.init()
    }
    
    override func configureDescription() {
        title = "Receive"
        updateTabBarIcon(name: .inbox)
    }
    
    override func configureBinds() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        self.navigationItem.rightBarButtonItem = shareButton
        contentView.amountTextField.addTarget(self, action: #selector(onAmountChange(_:)), for: .editingChanged)
        contentView.copyAddressButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        contentView.copyIntegratedAddressButton.addTarget(self, action: #selector(copyIntegratedAddresAction), for: .touchUpInside)
        contentView.copyPaymentIdButton.addTarget(self, action: #selector(copyPaymentIdAction), for: .touchUpInside)
        contentView.generatePaymentIdButton.addTarget(self, action: #selector(generatePaymentId), for: .touchUpInside)
        contentView.paymentIdTextField.addTarget(self, action: #selector(onPaymentIdTextFieldChange(_:)), for: .editingChanged)
        wallet.observe { [weak self] change, wallet in
            switch change {
            case .reset, .changedAddress(_):
                self?.setAddress()
            default:
                break
            }
        }
        
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
    
    @objc
    private func copyPaymentIdAction() {
        if let paymentId = paymentId {
            copy(text: paymentId)
        }
    }
    
    @objc
    private func copyIntegratedAddresAction() {
        if
            let integratedAddress = contentView.integratedAddressTextField.text,
            !integratedAddress.isEmpty {
            copy(text: integratedAddress)
        }
    }
    
    @objc
    private func generatePaymentId() {
        // FIX-ME: We don't need know anout MoneroWalletAdapter, but it's should not be part of WalletProtocol.
        guard let paymentId = MoneroWalletAdapter.generatePaymentId() else {
            return
        }
        
        self.paymentId = paymentId
        let integratedAddress = wallet.integratedAddress(for: paymentId)
        contentView.paymentIdTextField.text = paymentId
        contentView.integratedAddressTextField.text = integratedAddress
        setAddress()
    }
    
    @objc
    private func onPaymentIdTextFieldChange(_ textField: UITextField) {
        self.paymentId = textField.text
        
        if let paymentId = self.paymentId {
            let integratedAddress = wallet.integratedAddress(for: paymentId)
            contentView.integratedAddressTextField.text = integratedAddress
        }
        
        setAddress()
    }
    
    @objc
    private func onAmountChange(_ textField: UITextField) {
        guard let amountStr = textField.text else {
            return
        }
        
        amount = MoneroAmount(amount: amountStr)
        setQrCode(MoneroUri(address: wallet.address, paymentId: paymentId, amount: amount))
    }
    
    private func setAddress() {
        let address = wallet.address
        contentView.addressLabel.text = address
        setQrCode(MoneroUri(address: address, paymentId: paymentId, amount: amount))
    }
    
    private func setQrCode(_ uri: MoneroUri) {
        contentView.qrImageView.image = QRCode(uri.formatted())?.image
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
            UIPasteboard.general.string = self?.wallet.address
        }
        
        let sendEmailAction = UIAlertAction(title: "Send email", style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.sendEmail(text: this.wallet.address)
        }
        let sendTextMessageAction = UIAlertAction(title: "Send text message", style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.sendText(message: this.wallet.address)
        }
        
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.addAction(copyAction)
        alertViewController.addAction(sendEmailAction)
        alertViewController.addAction(sendTextMessageAction)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true)
    }
    
    @objc
    private func copyAction() {
        copy(text: wallet.address)
    }
    
    private func copy(text: String) {
        UIPasteboard.general.string = text
        let alert = UIAlertController(title: nil, message: "Copied", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let time = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: time){
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
