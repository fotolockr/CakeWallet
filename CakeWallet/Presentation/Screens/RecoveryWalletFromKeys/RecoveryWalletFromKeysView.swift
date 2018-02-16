//
//  RecoveryWalletsFromKeysView.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 14.02.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import UIKit

final class RecoveryWalletFromKeysView: BaseView {
    let nameTextField: UITextField
    let publicKeyTextField: UITextField
    let viewKeyTextField: UITextField
    let spendKeyTextField: UITextField
    let restoreHeightTextField: UITextField
    let watchOnlyDescriptionLabel: UILabel
    let confirmButton: UIButton
    
    required init() {
        nameTextField = FloatingLabelTextField(placeholder: "Wallet name")
        publicKeyTextField = FloatingLabelTextField(placeholder: "Address")
        viewKeyTextField = FloatingLabelTextField(placeholder: "View key (private)")
        spendKeyTextField = FloatingLabelTextField(placeholder: "Spend key (private)")
        restoreHeightTextField = FloatingLabelTextField(placeholder: "Restore height (optional)")
        confirmButton = PrimaryButton(title: "Recover")
        watchOnlyDescriptionLabel = UILabel(font: .avenirNextMedium(size: 14))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        restoreHeightTextField.keyboardType = .numberPad
        watchOnlyDescriptionLabel.numberOfLines = 0
        addSubview(nameTextField)
        addSubview(publicKeyTextField)
        addSubview(viewKeyTextField)
        addSubview(spendKeyTextField)
        addSubview(restoreHeightTextField)
        addSubview(watchOnlyDescriptionLabel)
        addSubview(confirmButton)
    }
    
    override func configureConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(20)
        }
        
        publicKeyTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
        }
        
        viewKeyTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalTo(publicKeyTextField.snp.bottom).offset(20)
        }
        
        watchOnlyDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalTo(spendKeyTextField.snp.bottom)
        }
        
        spendKeyTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalTo(viewKeyTextField.snp.bottom).offset(20)
        }
        
        restoreHeightTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.top.equalTo(watchOnlyDescriptionLabel.snp.bottom).offset(5)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
}
