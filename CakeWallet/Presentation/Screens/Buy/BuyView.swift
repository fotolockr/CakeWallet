//
//  BuyView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 15.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class BuyView: BaseView {
    let codeTextField: UITextField
    let addressTextField: UITextField
    let addressScanQrButton: UIButton
    let submitButton: UIButton
    let resetButton: UIButton
    let innerView: UIView
    let poweredByLabel: UILabel
    let addressDescriptionLabel: UILabel
    let walletDescirptionLabel: UILabel
    
    required init() {
        codeTextField = FloatingLabelTextField.init(placeholder: "Scratch card number")
        addressTextField = FloatingLabelTextField.init(placeholder: "Monero address")
        submitButton = PrimaryButton(title: "Redeem")
        resetButton = SecondaryButton(title: "RESET".uppercased())
        innerView = CardView()
        addressScanQrButton = SecondaryButton(
            image: UIImage.fontAwesomeIcon(
                name: .qrcode,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        poweredByLabel = UILabel(font: .avenirNextMedium(size: 13))
        addressDescriptionLabel = UILabel(font: .avenirNextMedium(size: 13))
        walletDescirptionLabel = UILabel(font: .avenirNextMedium(size: 13))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .whiteSmoke
        poweredByLabel.textAlignment = .center
        poweredByLabel.textColor = .lightGray
        innerView.addSubview(codeTextField)
        innerView.addSubview(addressTextField)
        innerView.addSubview(addressScanQrButton)
        innerView.addSubview(addressDescriptionLabel)
        innerView.addSubview(walletDescirptionLabel)
        addressDescriptionLabel.textColor = .lightGray
        addressDescriptionLabel.numberOfLines = 0
        walletDescirptionLabel.textColor = .lightGray
        walletDescirptionLabel.numberOfLines = 0
        addSubview(resetButton)
        addSubview(submitButton)
        addSubview(innerView)
        addSubview(poweredByLabel)
    }
    
    override func configureConstraints() {
        innerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        addressDescriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        codeTextField.snp.makeConstraints { make in
            make.top.equalTo(addressDescriptionLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(codeTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(addressScanQrButton.snp.leading).offset(-15)
        }
        
        addressScanQrButton.snp.makeConstraints { make in
            make.centerY.equalTo(addressTextField.snp.centerY)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(addressTextField.snp.height)
            make.width.equalTo(addressScanQrButton.snp.height)
        }
        
        walletDescirptionLabel.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.height.equalTo(50)
            make.leading.equalTo(self.snp.centerX).offset(10)
        }
        
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.height.equalTo(50)
            make.width.equalTo(submitButton.snp.width)
            make.trailing.equalTo(self.snp.centerX).offset(-10)
        }
        
        poweredByLabel.snp.makeConstraints { make in
            make.bottom.equalTo(submitButton.snp.top).offset(-15)
            make.centerX.equalToSuperview()
        }
    }
}
