//
//  NodeSettingsView.swift
//  CakeWallet
//
//  Created by FotoLockr on 10.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import UIKit

final class NodeSettingsView: BaseView {
    let nodeAddressLabel: UITextField
    let nodePortLabel: UITextField
    let loginLabel: UITextField
    let passwordLabel: UITextField
    let connectButton: UIButton
    let descriptionLabel: UILabel
    
    required init() {
        nodeAddressLabel = FloatingLabelTextField(placeholder: "Daemon address")
        nodePortLabel = FloatingLabelTextField(placeholder: "Daemon port")
        loginLabel = FloatingLabelTextField(placeholder: "Login (optional)")
        passwordLabel = FloatingLabelTextField(placeholder: "Password (optional)")
        connectButton = PrimaryButton(title: "Connect")
        descriptionLabel = UILabel(font: .avenirNextMedium(size: 17))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nodePortLabel.keyboardType = .numberPad
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        addSubview(nodeAddressLabel)
        addSubview(nodePortLabel)
        addSubview(loginLabel)
        addSubview(passwordLabel)
        addSubview(connectButton)
        addSubview(descriptionLabel)
    }
    
    override func configureConstraints() {
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        nodePortLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeAddressLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(nodePortLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.5).inset(15)
            make.trailing.equalTo(passwordLabel.snp.leading).offset(-10)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.top)
            make.width.equalTo(loginLabel.snp.width)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(descriptionLabel.snp.height)
        }
        
        connectButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
}
