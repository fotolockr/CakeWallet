//
//  ExchangeResultViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 22.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import QRCode

final class ExchangeResultViewController: BaseViewController<ExchangeResultView> {
    enum Row: Int, Stringify {
        case id, minAmount, maxAmount, address
        
        func stringify() -> String {
            let str: String
            
            switch self {
            case .id:
                str = "Morph id"
            case .minAmount:
                str = "Min"
            case .maxAmount:
                str = "Max"
            case .address:
                str = "Address"
            }
            
            return str
        }
    }
    
    var presentVerifyPinScreen: ((@escaping () -> Void) -> Void)?
    
    private let account: Account
    private let transactionCreation: TransactionCreatableProtocol
    private let amountStr: String
    private let amount: Amount
    private let trade: ExchangeTrade
    
    init(account: Account, trade: ExchangeTrade, amountStr: String) {
        self.account = account
        self.trade = trade
        self.amountStr = amountStr
        self.amount = MoneroAmount(amount: amountStr)
        self.transactionCreation = account.currentWallet
        super.init()
    }
    
    override func configureDescription() {
        title = "Deposit"
    }
    
    override func configureBinds() {
        contentView.confirmDescriptionLabel.text = "* Please copy or write down your ID shown above"
        contentView.confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        contentView.copyDepositButton.addTarget(self, action: #selector(copyAddressAction), for: .touchUpInside)
        contentView.copyTradeIdButton.addTarget(self, action: #selector(copyTradeIdAction), for: .touchUpInside)
        setDepositId(trade.id)
        setMaxDepositAmount(trade.max.formatted())
        setMinDepositAmount(trade.min.formatted())
        setAddressDepositAmount(trade.inputAddress)
        
        if trade.inputCurrency == .monero {
            contentView.preConfirmDescriptionLabel.text = "By pressing confirm, you will be sending \(amount.formatted()) XMR from your wallet called \(account.currentWallet.name) to the address shown above.\n\nPlease press confirm to continue or go back to change the amounts."
        } else {
            contentView.preConfirmDescriptionLabel.text = "Please send \(amount.formatted()) \(amount.formatted()) to the address/QR code shown above"
            contentView.confirmButton.isHidden = true
        }
    }
    
    @objc
    private func confirmAction() {
        sendMonero()
    }
    
    @objc
    private func copyAddressAction() {
        copyText(trade.inputAddress)
    }
    
    @objc
    private func copyTradeIdAction() {
        copyText(trade.id)
    }
    
    @objc
    private func confirm() {
        let alert = UIAlertController(title: nil, message:  "Send XMR \(amount.formatted()) to exchange ?", preferredStyle: .alert)
        let send = UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            self?.presentVerifyPinScreen?() {
                self?.sendMonero()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(send)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func sendMonero() {
        guard trade.min.value <= amount.value else {
            let message = "Sending amount of \(trade.inputCurrency.symbol) \(amount.formatted()) is less than the minimum allowed (\(trade.inputCurrency.symbol) \(trade.min.formatted()))"
            UIAlertController.showInfo(title: "Incorrect amount value", message: message, presentOn: self)
            return
        }
        
        guard trade.max.value >= amount.value else {
            let message = "Sending amount of \(trade.inputCurrency.symbol) \(amount.formatted()) is more than the maximimum allowed (\(trade.inputCurrency.symbol) \(trade.min.formatted()))"
            UIAlertController.showInfo(title: "Incorrect amount value", message: message, presentOn: self)
            return
        }
        
        let alert = UIAlertController.showSpinner(message: "Sending")
        present(alert, animated: true)
        transactionCreation.createTransaction(
            to: trade.inputAddress,
            withPaymentId: "",
            amount: amount,
            priority: account.transactionPriority)
            .then { pdtx in return pdtx.commit() }
            .then { [weak self] _ -> Void in
                if let this = self {
                    alert.dismiss(animated: false) {
                        UIAlertController.showInfo(title: "Funds sent", message: "Your funds were sent to the exchange.", presentOn: this)
                    }
                }
            }.catch { error in
                alert.dismiss(animated: true) {
                    UIAlertController.showError(title: nil, message: error.localizedDescription, presentOn: self)
                }
        }
    }
    
    private func setDepositId(_ id: String) {
        contentView.tradeIdLabel.text = "ID: \(id)"
    }
    
    private func setMinDepositAmount(_ amount: String) {
        contentView.minAmountLabel.text = "Min: \(trade.inputCurrency.symbol) \(amount)"
    }
    
    private func setMaxDepositAmount(_ amount: String) {
        contentView.maxAmountLabel.text = "Max: \(trade.inputCurrency.symbol) \(amount)"
    }
    
    private func setAddressDepositAmount(_ address: String) {
        contentView.depositAddressLabel.text = "Address: \(address)"
        setQr(address)
    }
    
    private func setQr(_ text: String) {
        let qr = QRCode(text)
        contentView.depositQrCodeImageView.image = qr?.image
    }
    
    private func copyText(_ text: String) {
        UIPasteboard.general.string = text
        let alert = UIAlertController(title: nil, message: "Copied", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let time = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: time){
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
