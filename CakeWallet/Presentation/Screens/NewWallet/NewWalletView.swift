//
//  NewwalletView.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit
import SnapKit

final class NewWalletView: BaseView {
    let walletNameTextField: UITextField
    let nextButton: UIButton
    
    required init() {
        walletNameTextField = FloatingLabelTextField(placeholder: "Wallet name")
        nextButton = PrimaryButton(title: "Continue")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addSubview(walletNameTextField)
        addSubview(nextButton)
    }
    
    override func configureConstraints() {
        walletNameTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-60)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(walletNameTextField.snp.height)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(walletNameTextField.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(nextButton.snp.width)
            make.height.equalTo(50)
        }
    }
}
