//
//  DonationVieew.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 20.02.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import UIKit

final class DonationView: BaseView {
    let qrImageView: UIImageView
    let addressLabel: UILabel
    let amountTextField: UITextField
    let submitButton: UIButton
    
    required init() {
        qrImageView = UIImageView()
        amountTextField = FloatingLabelTextField(placeholder: "Amount")
        submitButton = PrimaryButton(title: "Send something to us")
        addressLabel = UILabel(font: .avenirNextMedium(size: 17))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addSubview(qrImageView)
        addSubview(amountTextField)
        addSubview(submitButton)
        addSubview(addressLabel)
    }
    
    override func configureConstraints() {
        qrImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(qrImageView.snp.width)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.bottom.equalTo(submitButton.snp.top).offset(-50)
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
            make.top.equalTo(qrImageView.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
