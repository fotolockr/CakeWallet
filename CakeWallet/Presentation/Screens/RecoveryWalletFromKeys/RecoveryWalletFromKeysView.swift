//
//  RecoveryWalletsFromKeysView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 14.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class RecoveryWalletFromKeysView: BaseView {
    let nameTextField: UITextField
    let publicKeyTextField: UITextField
    let viewKeyTextField: UITextField
    let spendKeyTextField: UITextField
    let watchOnlyDescriptionLabel: UILabel
    let restoreFromHeightView: RestoreFromHeightView
    let confirmButton: UIButton
    let scrollView: UIScrollView
    let contentView: UIView
    
    required init() {
        nameTextField = FloatingLabelTextField(placeholder: "Wallet name")
        publicKeyTextField = FloatingLabelTextField(placeholder: "Address")
        viewKeyTextField = FloatingLabelTextField(placeholder: "View key (private)")
        spendKeyTextField = FloatingLabelTextField(placeholder: "Spend key (private)")
        confirmButton = PrimaryButton(title: "Recover")
        watchOnlyDescriptionLabel = UILabel(font: .avenirNextMedium(size: 14))
        restoreFromHeightView = RestoreFromHeightView()
        scrollView = UIScrollView()
        contentView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        watchOnlyDescriptionLabel.numberOfLines = 0
        contentView.addSubview(nameTextField)
        contentView.addSubview(publicKeyTextField)
        contentView.addSubview(viewKeyTextField)
        contentView.addSubview(spendKeyTextField)
        contentView.addSubview(restoreFromHeightView)
        contentView.addSubview(watchOnlyDescriptionLabel)
        contentView.addSubview(confirmButton)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
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
        
        restoreFromHeightView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(watchOnlyDescriptionLabel.snp.bottom).offset(5)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            
            switch UIScreen.main.sizeType {
            case .iPhone4, .iPhone5, .iPhone6:
                make.top.equalTo(restoreFromHeightView.snp.bottom).offset(20)
            default:
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
}
