//
//  DonationVieew.swift
//  CakeWallet
//
//  Created by Cake Technologies on 20.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class DonationView: BaseView {
    private static let qrImageViewSize = CGSize(width: 225, height: 225)
    let qrImageView: UIImageView
    let addressLabel: UILabel
    let amountTextField: UITextField
    let submitButton: UIButton
    let descriptionAddress: UILabel
    let scrollView: UIScrollView
    let contentView: UIView
    
    required init() {
        qrImageView = UIImageView()
        amountTextField = FloatingLabelTextField(placeholder: "Amount")
        submitButton = PrimaryButton(title: "Send something to us")
        addressLabel = CopyableLabel(font: .avenirNextMedium(size: 15))
        descriptionAddress = UILabel(font: .avenirNextBold(size: 12))
        scrollView = UIScrollView()
        contentView = UIView()
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
        contentView.addSubview(qrImageView)
        contentView.addSubview(amountTextField)
        contentView.addSubview(submitButton)
        contentView.addSubview(addressLabel)
        contentView.addSubview(descriptionAddress)
        contentView.backgroundColor = backgroundColor
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
        
        qrImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(DonationView.qrImageViewSize.height)
            make.width.equalTo(DonationView.qrImageViewSize.width)
        }
        
        switch UIScreen.main.sizeType {
        case  .iPhone4, .iPhone5, .iPhone6:
            amountTextField.snp.makeConstraints { make in
                make.top.equalTo(addressLabel.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
            }
            
            submitButton.snp.makeConstraints { make in
                make.top.equalTo(amountTextField.snp.bottom).offset(15)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(50)
            }
        default:
            amountTextField.snp.makeConstraints { make in
                make.bottom.equalTo(submitButton.snp.top).offset(-35)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
            }
            
            submitButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(50)
            }
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
