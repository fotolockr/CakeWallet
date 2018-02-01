//
//  BalanceView.swift
//  CakeWallet
//
//  Created by FotoLockr on 26.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import UIKit

final class BalanceView: BaseView {
    let balanceLabel: UILabel
    let unlockedBalanceLabel: UILabel
    let alternativeBalanceLabel: UILabel
    let balanceDescriptionLabel: UILabel
    let alternativeBalanceDescriptionLabel: UILabel
    let unlockedBalanceDescriptionLabel: UILabel
    var balance: String {
        get {
            return balanceLabel.text ?? ""
        }
        
        set {
            balanceLabel.text = newValue
        }
    }
    
    var alternativeBalance: String {
        get {
            return alternativeBalanceLabel.text ?? ""
        }
        
        set {
            alternativeBalanceLabel.text = newValue
        }
    }
    
    var unlockedBalance: String {
        get {
            return unlockedBalanceLabel.text ?? ""
        }
        
        set {
            unlockedBalanceLabel.text = newValue
        }
    }
    
    required init() {
        unlockedBalanceLabel = UILabel(font: .avenirNextDemiBold(size: 19))
        balanceLabel = UILabel(font: .avenirNextDemiBold(size: 28))
        alternativeBalanceLabel = UILabel(font: .avenirNextDemiBold(size: 19))
        balanceDescriptionLabel = UILabel(font: .avenirNextMedium(size: 13))
        unlockedBalanceDescriptionLabel = UILabel(font: .avenirNextMedium(size: 11))
        alternativeBalanceDescriptionLabel = UILabel(font: .avenirNextMedium(size: 11))
        super.init()
        balance = "N/A"
        alternativeBalance = "N/A"
        unlockedBalance = "N/A"
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        balanceDescriptionLabel.text = "Total balance (XMR)".uppercased()
        balanceDescriptionLabel.textColor = .lightGray
        balanceLabel.numberOfLines = 0
        alternativeBalanceDescriptionLabel.text = "Rate balance (USD)".uppercased()
        alternativeBalanceDescriptionLabel.textColor = .lightGray
        unlockedBalanceDescriptionLabel.text = "Available  balance (XMR)".uppercased()
        unlockedBalanceDescriptionLabel.textColor = .lightGray
        
        // FIX-ME: Unnamed constant
        
        alternativeBalanceLabel.textColor = UIColor(hex: 0x303030)
        
        // FIX-ME: Unnamed constant
        
        balanceLabel.textColor = UIColor(hex: 0x303030)
        
        // FIX-ME: Unnamed constant
        
        unlockedBalanceLabel.textColor = UIColor(hex: 0x303030)
        alternativeBalanceLabel.text = "N/A"
        addSubview(unlockedBalanceDescriptionLabel)
        addSubview(balanceDescriptionLabel)
        addSubview(alternativeBalanceDescriptionLabel)
        addSubview(unlockedBalanceLabel)
        addSubview(balanceLabel)
        addSubview(alternativeBalanceLabel)
    }
    
    override func configureConstraints() {
        balanceDescriptionLabel.snp.makeConstraints { make in
            make.width.equalTo(balanceDescriptionLabel.snp.width)
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(balanceDescriptionLabel.snp.leading)
            make.trailing.equalToSuperview()
            make.top.equalTo(balanceDescriptionLabel.snp.bottom)
            make.height.equalTo(balanceLabel.snp.height)
        }
        
        unlockedBalanceDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(10)
            make.width.equalTo(unlockedBalanceLabel.snp.width)
            make.leading.equalTo(balanceLabel.snp.leading)
        }
        
        unlockedBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(unlockedBalanceDescriptionLabel.snp.bottom)
            make.trailing.equalTo(balanceLabel.snp.trailing)
            make.leading.equalTo(unlockedBalanceDescriptionLabel.snp.leading)
        }
        
        alternativeBalanceDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(unlockedBalanceLabel.snp.leading)
            make.top.equalTo(unlockedBalanceLabel.snp.bottom).offset(5)
            make.width.equalTo(balanceDescriptionLabel.snp.width)
        }
        
        alternativeBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(alternativeBalanceDescriptionLabel.snp.bottom)
            make.trailing.equalTo(balanceLabel.snp.trailing)
            make.leading.equalTo(alternativeBalanceDescriptionLabel.snp.leading)
        }
        
        self.snp.makeConstraints { make in
            make.bottom.equalTo(alternativeBalanceLabel.snp.bottom)
        }
    }
}

