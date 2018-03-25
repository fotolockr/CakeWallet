//
//  DisclaimerViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies 24.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class DisclaimerViewController: BaseViewController<DisclaimerView> {
    
    // MARK: Property injections
    
    var onAccept: (() -> Void)?
    var onCancel: (() -> Void)?
    
    override func configureBinds() {
        loadAndDisplayDocument()
        contentView.acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        contentView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    @objc
    private func accept() {
        onAccept?()
    }
    
    @objc
    private func cancel() {
        onCancel?()
    }
    
    private func loadAndDisplayDocument() {
        if let docUrl = Configurations.termsOfUseUrl {
            do {
                let attributedText = try NSAttributedString(
                    url: docUrl,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil)
                contentView.textView.attributedText = attributedText
            } catch {
                print(error)
            }
        }
    }
}
