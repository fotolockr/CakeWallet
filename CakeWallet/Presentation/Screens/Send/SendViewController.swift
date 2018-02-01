//
//  SendViewController.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import FontAwesome_swift

final class SendViewController: BaseViewController<SendView> {
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    private let estimatedFeeCalculation: EstimatedFeeCalculable
    private let transactionCreation: TransactionCreatableProtocol
    private let priority: TransactionPriority
    private let rateTicker: RateTicker
    private var address: String
    private var amount: String
    private var rateAmount: String {
        get {
            return contentView.amountInAnotherCuncurrencyTextField.text ?? ""
        }
        
        set {
            contentView.amountInAnotherCuncurrencyTextField.text = newValue
        }
    }
    private var paymentId: String {
        get {
            return contentView.paymenyIdTextField.text ?? ""
        }
        
        set {
            contentView.paymenyIdTextField.text = newValue
        }
    }
    
    convenience init(accountSettings: AccountSettingsConfigurable, estimatedFeeCalculation: EstimatedFeeCalculable, transactionCreation: TransactionCreatableProtocol, rateTicker: RateTicker) {
        self.init(
            transactionPriority: accountSettings.transactionPriority,
            estimatedFeeCalculation: estimatedFeeCalculation,
            transactionCreation: transactionCreation,
            rateTicker: rateTicker)
    }
    
    init(transactionPriority: TransactionPriority, estimatedFeeCalculation: EstimatedFeeCalculable, transactionCreation: TransactionCreatableProtocol, rateTicker: RateTicker) {
        self.priority = transactionPriority
        self.estimatedFeeCalculation = estimatedFeeCalculation
        self.transactionCreation = transactionCreation
        self.rateTicker = rateTicker
        address = ""
        amount = ""
        super.init()
    }
    
    override func configureBinds() {
        title = "Send"
        
        contentView.feePriorityDescriptionLabel.text = "Currently the fee is set at \(priority.stringify()) priority. Transaction priority can be adjusted in the settings."
        
        estimatedFeeCalculation.calculateEstimatedFee(forPriority: priority)
            .then(on: DispatchQueue.main) { [weak self] amount in
                self?.contentView.estimatedValueLabel.text = amount.formatted()
            }.catch(on: DispatchQueue.main) { [weak self] error in
                self?.showError(error)
        }
        
        contentView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        contentView.qrScanButton.addTarget(self, action: #selector(scanAddressFromQr), for: .touchUpInside)
        contentView.addressTextField.addTarget(self, action: #selector(onAddressTextChange(_:)), for: .editingChanged)
        contentView.amountInMoneroTextField.addTarget(self, action: #selector(onAmountTextChange(_:)), for: .editingChanged)
        contentView.amountInAnotherCuncurrencyTextField.addTarget(self, action: #selector(onAlternativeAmountTextChange(_:)), for: .editingChanged)
    }
    
    @objc
    private func scanAddressFromQr() {
        readerVC.completionBlock = { [weak self] result in
            // FIX-ME: HARDCODED VALUES FOR MONERO
            
            if
                var address = result?.value,
                address.hasPrefix("monero:"),
                let range = address.range(of: "monero:") {
                address.removeSubrange(range)
                self?.contentView.addressTextField.text = address
                self?.address = address
            } else if let address = result?.value {
                self?.contentView.addressTextField.text = address
                self?.address = address
            }
            
            self?.readerVC.stopScanning()
            self?.readerVC.dismiss(animated: true)
        }
        
        readerVC.modalPresentationStyle = .overFullScreen
        parent?.present(readerVC, animated: true)
    }
    
    @objc
    private func send() {
        let alert = UIAlertController(
            title: "Creating transaction",
            message: "Confirm sending",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.createTransaction()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        parent?.present(alert, animated: true)
    }
    
    @objc
    private func onAddressTextChange(_ textField: UITextField) {
        address = textField.text ?? ""
    }
    
    @objc
    private func onAmountTextChange(_ textField: UITextField) {
        amount = textField.text ?? ""
        rateAmount = convertXMRtoUSD(amount: amount, rate: rateTicker.rate)
    }
    
    @objc
    private func onAlternativeAmountTextChange(_ textField: UITextField) {
        rateAmount = textField.text ?? ""
        amount = convertUSDtoXMR(amount: rateAmount, rate: rateTicker.rate)
        contentView.amountInMoneroTextField.text = amount
    }
    
    private func createTransaction() {
        let alert = UIAlertController.showSpinner(message: "Creating transaction")
        parent?.present(alert, animated: true)
        
        transactionCreation.createTransaction(
            to: address,
            withPaymentId: paymentId,
            amount: MoneroAmount(amount: amount.replacingOccurrences(of: ",", with: ".")),
            priority: priority)
            .then(on: DispatchQueue.main) { [weak self] pendingTransaction -> Void in
                alert.dismiss(animated: true) {
                    self?.commitPendingTransaction(pendingTransaction)
                }
            }.catch(on: DispatchQueue.main) { [weak self] error in
                alert.dismiss(animated: true) {
                    self?.showError(error)
                }
        }
    }
    
    private func commitPendingTransaction(_ pendingTransaction: PendingTransaction) {
        let txDescription = pendingTransaction.description
        let alert = UIAlertController(
            title: "Confirm sending",
            message: "Commit transaction\nAmount: \(txDescription.amount.formatted())\nFee: \(txDescription.fee.formatted())",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
            pendingTransaction.commit()
                .then(on: DispatchQueue.main) { [weak self] _ -> Void in
                    self?.resetForm()
                    self?.showSentTx(description: pendingTransaction.description)
                }.catch(on: DispatchQueue.main) { [weak self] error in
                    self?.showError(error)
                }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        parent?.present(alert, animated: true)
    }
    
    private func resetForm() {
        contentView.amountInMoneroTextField.text = ""
        amount = ""
        rateAmount = ""
        contentView.addressTextField.text = ""
        address = ""
        paymentId = ""
    }
    
    private func showSentTx(description: PendingTransactionDescription) {
        let alert = UIAlertController(
            title: "Transaction created",
            message: "Transaction created!",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(ok)
        parent?.present(alert, animated: true)
    }
}


