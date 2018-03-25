//
//  ExchangeResultView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 22.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class ExchangeResultView: BaseView {
    let depositInfoView: UIView
    let tradeIdLabel: UILabel
    let minAmountLabel: UILabel
    let maxAmountLabel: UILabel
    let depositAddressLabel: UILabel
    let copyDepositButton: UIButton
    let depositQrCodeImageView: UIImageView
    let confirmButton: UIButton
    let confirmDescriptionLabel: UILabel
    let preConfirmDescriptionLabel: UILabel
    let copyTradeIdButton: UIButton
    let lineSeparateView: UIView
    
    required init() {
        tradeIdLabel = UILabel(font: .avenirNextMedium(size: 15))
        minAmountLabel = UILabel(font: .avenirNextMedium(size: 15))
        maxAmountLabel = UILabel(font: .avenirNextMedium(size: 15))
        depositAddressLabel = CopyableLabel()
        depositInfoView = CardView()
        copyDepositButton = SecondaryButton(title: "Copy address".uppercased())
        depositQrCodeImageView = UIImageView()
        confirmButton = PrimaryButton(title: "Confirm".uppercased())
        confirmDescriptionLabel = UILabel(font: .avenirNextMedium(size: 15))
        preConfirmDescriptionLabel = UILabel(font: .avenirNextMedium(size: 15))
        copyTradeIdButton = SecondaryButton(title: "Copy morph ID".uppercased())
        lineSeparateView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        depositAddressLabel.numberOfLines = 0
        preConfirmDescriptionLabel.numberOfLines = 0
        preConfirmDescriptionLabel.textColor = .lightGray
        confirmDescriptionLabel.textColor = .lightGray
        confirmDescriptionLabel.numberOfLines = 0
        lineSeparateView.backgroundColor = .lightGray
        depositAddressLabel.font = .avenirNextMedium(size: 13)
        depositInfoView.addSubview(lineSeparateView)
        depositInfoView.addSubview(tradeIdLabel)
        depositInfoView.addSubview(copyDepositButton)
        depositInfoView.addSubview(minAmountLabel)
        depositInfoView.addSubview(maxAmountLabel)
        depositInfoView.addSubview(depositAddressLabel)
        depositInfoView.addSubview(depositQrCodeImageView)
        depositInfoView.addSubview(confirmDescriptionLabel)
        depositInfoView.addSubview(copyTradeIdButton)
        depositInfoView.addSubview(preConfirmDescriptionLabel)
        addSubview(depositInfoView)
        addSubview(confirmButton)
    }
    
    override func configureConstraints() {
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        depositInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(25)
        }
        
        tradeIdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(depositQrCodeImageView.snp.leading).offset(-5)
//            make.top.equalToSuperview().offset(15)
            make.bottom.equalTo(minAmountLabel.snp.top).offset(-5)
        }
        
        minAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(depositQrCodeImageView.snp.leading).offset(-5)
            make.centerY.equalTo(depositQrCodeImageView.snp.centerY)
//            make.top.equalTo(tradeIdLabel.snp.bottom).offset(5)
        }
        
        maxAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(depositQrCodeImageView.snp.leading).offset(-5)
            make.top.equalTo(minAmountLabel.snp.bottom).offset(5)
        }
        
        depositAddressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalTo(depositQrCodeImageView.snp.bottom).offset(15)
        }
        
        preConfirmDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(depositAddressLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        confirmDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalTo(preConfirmDescriptionLabel.snp.bottom).offset(10)
        }
        
        copyDepositButton.snp.makeConstraints { make in
            make.top.equalTo(confirmDescriptionLabel.snp.bottom).offset(15)
            make.trailing.equalTo(self.snp.centerX).offset(-10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        copyTradeIdButton.snp.makeConstraints { make in
            make.top.equalTo(confirmDescriptionLabel.snp.bottom).offset(15)
            make.leading.equalTo(self.snp.centerX).offset(10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        depositQrCodeImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(150)
            make.width.equalTo(150)
        }
        
        lineSeparateView.snp.makeConstraints { make in
            make.top.equalTo(depositAddressLabel.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
    }
}
