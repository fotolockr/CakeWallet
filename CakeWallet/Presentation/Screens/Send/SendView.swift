//
//  SendView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class SendView: BaseView {
    let addressTextField: UITextField
    let amountInMoneroTextField: UITextField
    let amountInAnotherCuncurrencyTextField: FloatingLabelTextField
    let paymenyIdTextField: UITextField
    let sendButton: UIButton
    let qrScanButton: UIButton
    let estimatedTitleLabel: UILabel
    let estimatedValueLabel: UILabel
    let feePriorityDescriptionLabel: UILabel
    let allAmountButton: UIButton
    let innerView: CardView
    
    required init() {
        addressTextField = FloatingLabelTextField(placeholder: "Monero address")
        amountInMoneroTextField = FloatingLabelTextField(placeholder: "XMR: 0.0000", title: "XMR")
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
        estimatedTitleLabel = UILabel(font: .avenirNextMedium(size: 15))
        estimatedValueLabel = UILabel(font: .avenirNextMedium(size: 15))
        feePriorityDescriptionLabel = UILabel(font: .avenirNextMedium(size: 12))
        allAmountButton = SecondaryButton(title: "All".uppercased())
        innerView = CardView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        amountInMoneroTextField.keyboardType = .decimalPad
        amountInAnotherCuncurrencyTextField.keyboardType = .decimalPad
        innerView.addSubview(paymenyIdTextField)
        innerView.addSubview(addressTextField)
        innerView.addSubview(amountInMoneroTextField)
        innerView.addSubview(amountInAnotherCuncurrencyTextField)
        innerView.addSubview(qrScanButton)
        
        innerView.addSubview(estimatedTitleLabel)
        innerView.addSubview(estimatedValueLabel)
        innerView.addSubview(feePriorityDescriptionLabel)
        innerView.addSubview(allAmountButton)
        addSubview(sendButton)
        addSubview(innerView)
        
        backgroundColor = .whiteSmoke
        feePriorityDescriptionLabel.numberOfLines = 0
        feePriorityDescriptionLabel.textColor = .gray
        estimatedTitleLabel.text = "Estimated fee:"
        estimatedValueLabel.text = "0"
        estimatedValueLabel.textAlignment = .right
    }
    
    override func configureConstraints() {
        let allAmountButtonWidth = 75
        
        innerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(qrScanButton.snp.leading).offset(-15)
        }
        
        qrScanButton.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.top)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(addressTextField.snp.centerY)
            make.width.equalTo(95)
        }
        
        paymenyIdTextField.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        allAmountButton.snp.makeConstraints { make in
            make.top.equalTo(amountInMoneroTextField.snp.top)
            make.leading.equalTo(amountInAnotherCuncurrencyTextField.snp.trailing).offset(15)
            make.width.equalTo(allAmountButtonWidth)
            make.height.equalTo(amountInMoneroTextField.snp.height)
        }
        
        amountInMoneroTextField.snp.makeConstraints { make in
            make.top.equalTo(paymenyIdTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.width.greaterThanOrEqualToSuperview().multipliedBy(0.4).inset(10 + allAmountButtonWidth)
            make.trailing.equalTo(amountInAnotherCuncurrencyTextField.snp.leading).offset(-15)
        }
        
        amountInAnotherCuncurrencyTextField.snp.makeConstraints { make in
            make.top.equalTo(amountInMoneroTextField.snp.top)
            make.width.equalTo(amountInMoneroTextField.snp.width)
            make.trailing.equalToSuperview().offset(-25 + (allAmountButtonWidth * -1))
        }
        
        sendButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.height.equalTo(50)
        }
        
        estimatedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountInMoneroTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(estimatedValueLabel.snp.leading)
        }
        
        estimatedValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(estimatedValueLabel.snp.width)
            make.centerY.equalTo(estimatedTitleLabel.snp.centerY)
        }
        
        feePriorityDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(estimatedTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
}
