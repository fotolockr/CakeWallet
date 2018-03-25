//
//  BuyViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 10.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import QRCodeReader

final class BuyViewController: BaseViewController<BuyView> {
    private let wallet: WalletProtocol
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    init(wallet: WalletProtocol) {
        self.wallet = wallet
        super.init()
    }
    
    override func configureDescription() {
        title = "Redeem"
    }
    
    override func configureBinds() {
        wallet.observe { [weak self] (change, wallet) in
            switch change {
            case let .changedAddress(address):
                self?.contentView.addressTextField.text = address
            case .reset:
                self?.contentView.addressTextField.text = wallet.address
            default:
                break
            }
        }
        
        contentView.addressDescriptionLabel.text = "To redeem a QWKMonero card, enter the scratch-off card number below."
        contentView.walletDescirptionLabel.text = "The xmr will be deposited into your wallet (\(wallet.name)) unless you change the xmr address in the above field."
        contentView.resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        contentView.addressScanQrButton.addTarget(self, action: #selector(scanQrAction), for: .touchUpInside)
        contentView.poweredByLabel.attributedText =  NSAttributedString(
            string: "Powered by QWKMonero.com",
            attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
    }
    
    @objc
    private func resetAction() {
        let alert = UIAlertController(title: "Reset redeem", message: "Are you sure that reset redeem ?", preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.reset()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc
    private func scanQrAction() {
        readerVC.completionBlock = { [weak self] result in
            if let value = result?.value {
                let result = MoneroQRResult(value: value)
                self?.contentView.addressTextField.text = result.address
            }
            
            self?.readerVC.stopScanning()
            self?.readerVC.dismiss(animated: true)
        }
        
        readerVC.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(readerVC, animated: true)
    }
    
    private func reset() {
        contentView.codeTextField.text = nil
    }
}

