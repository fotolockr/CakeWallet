//
//  SendView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class FloatingLabelTextField: SkyFloatingLabelTextField {
    convenience init(placeholder: String) {
        self.init(placeholder: placeholder, title: placeholder)
    }
    
    init(placeholder: String, title: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.title = title
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        //        backgroundColor = .gray
    }
}

final class SendView: BaseView {
    let addressTextField: UITextField
    let amountInMoneroTextField: UITextField
    let amountInAnotherCuncurrencyTextField: UITextField
    let paymenyIdTextField: UITextField
    let sendButton: UIButton
    let qrScanButton: UIButton
    let estimatedTitleLabel: UILabel
    let estimatedValueLabel: UILabel
    let feePriorityDescriptionLabel: UILabel
    
    required init() {
        addressTextField = FloatingLabelTextField(placeholder: "Monero address")
        amountInMoneroTextField = FloatingLabelTextField(placeholder: "Monero: 0.0000", title: "Monero")
        amountInAnotherCuncurrencyTextField = FloatingLabelTextField(placeholder: "USD: 0.00", title: "USD (approximate)")
        paymenyIdTextField = FloatingLabelTextField(placeholder: "Payment ID (optional)", title: "Payment ID")
        sendButton = PrimaryButton(title: "Send".uppercased())
        let _qrScanButton = SecondaryButton(title: "Scan".uppercased())
        qrScanButton = _qrScanButton
        _qrScanButton.setLeftImage(
            UIImage.fontAwesomeIcon(
                name: .qrcode,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        estimatedTitleLabel = UILabel(font: .avenirNextMedium(size: 17))
        estimatedValueLabel = UILabel(font: .avenirNextMedium(size: 14))
        feePriorityDescriptionLabel = UILabel(font: .avenirNextMedium(size: 14))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        amountInMoneroTextField.keyboardType = .decimalPad
        amountInAnotherCuncurrencyTextField.keyboardType = .decimalPad
        addSubview(paymenyIdTextField)
        addSubview(addressTextField)
        addSubview(amountInMoneroTextField)
        addSubview(amountInAnotherCuncurrencyTextField)
        addSubview(qrScanButton)
        addSubview(sendButton)
        addSubview(estimatedTitleLabel)
        addSubview(estimatedValueLabel)
        addSubview(feePriorityDescriptionLabel)
        feePriorityDescriptionLabel.numberOfLines = 0
        feePriorityDescriptionLabel.textColor = .gray
        estimatedTitleLabel.text = "Estimated fee:"
        estimatedValueLabel.text = "0"
    }
    
    override func configureConstraints() {
        addressTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(qrScanButton.snp.leading).offset(-10)
        }
        
        qrScanButton.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.top)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(addressTextField.snp.centerY)
            make.width.equalTo(95)
        }
        
        paymenyIdTextField.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        amountInMoneroTextField.snp.makeConstraints { make in
            make.top.equalTo(paymenyIdTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.greaterThanOrEqualToSuperview().multipliedBy(0.5).inset(15)
            make.trailing.equalTo(amountInAnotherCuncurrencyTextField.snp.leading).offset(-10)
        }
        
        amountInAnotherCuncurrencyTextField.snp.makeConstraints { make in
            make.top.equalTo(amountInMoneroTextField.snp.top)
            make.width.equalTo(amountInMoneroTextField.snp.width)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(50)
        }
        
        estimatedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountInMoneroTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(estimatedValueLabel.snp.leading)
        }
        
        estimatedValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(estimatedValueLabel.snp.width)
            make.centerY.equalTo(estimatedTitleLabel.snp.centerY)
        }
        
        feePriorityDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(estimatedTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
