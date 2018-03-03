//
//  DonationVieew.swift
//  CakeWallet
//
//  Created by Cake Technologies on 20.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class DonationView: BaseView {
    let qrImageView: UIImageView
    let addressLabel: UILabel
    let amountTextField: UITextField
    let submitButton: UIButton
    let descriptionAddress: UILabel
    
    required init() {
        qrImageView = UIImageView()
        amountTextField = FloatingLabelTextField(placeholder: "Amount")
        submitButton = PrimaryButton(title: "Send something to us")
        addressLabel = CopyableLabel(font: .avenirNextMedium(size: 17))
        descriptionAddress = UILabel(font: .avenirNextBold(size: 15))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.isUserInteractionEnabled = true
        amountTextField.keyboardType = .decimalPad
        descriptionAddress.textAlignment = .center
        descriptionAddress.numberOfLines = 0
        addSubview(qrImageView)
        addSubview(amountTextField)
        addSubview(submitButton)
        addSubview(addressLabel)
        addSubview(descriptionAddress)
    }
    
    override func configureConstraints() {
        qrImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(qrImageView.snp.width)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.bottom.equalTo(submitButton.snp.top).offset(-35)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        submitButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionAddress.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionAddress.snp.makeConstraints { make in
            make.top.equalTo(qrImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
