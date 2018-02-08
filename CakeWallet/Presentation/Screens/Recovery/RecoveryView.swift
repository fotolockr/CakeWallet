//
//  RecoveryView.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//w

import UIKit
import SnapKit

final class RecoveryView: BaseView {
    let walletNameTextField: UITextField
    let seedTextView: UITextView
    let confirmButton: UIButton
    let placeholderLabel : UILabel
    
    required init() {
        walletNameTextField = FloatingLabelTextField(placeholder: "Enter wallets name", title: "Wallet name")
        seedTextView = UITextView()
        confirmButton = PrimaryButton(title: "Recover")
        placeholderLabel = UILabel(font: UIFont.avenirNextMedium(size: 17))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        seedTextView.delegate = self
       
        placeholderLabel.text = "Enter seed"
        placeholderLabel.sizeToFit()
        seedTextView.addSubview(placeholderLabel)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.isHidden = !seedTextView.text.isEmpty
        
        seedTextView.font = UIFont.avenirNextMedium(size: 17)
        seedTextView.backgroundColor = .groupTableViewBackground
        seedTextView.layer.masksToBounds = true
        seedTextView.layer.cornerRadius = 10
        addSubview(walletNameTextField)
        addSubview(seedTextView)
        addSubview(confirmButton)
    }
    
    override func configureConstraints() {
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
        
        seedTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        walletNameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(seedTextView.snp.top).offset(-20)
            make.leading.equalTo(seedTextView.snp.leading)
            make.trailing.equalTo(seedTextView.snp.trailing)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
}

extension RecoveryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
