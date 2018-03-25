//
//  RecoveryWalletOptions.swift
//  CakeWallet
//
//  Created by Cake Technologies on 14.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class RecoveryWalletOptionsView: BaseView {
    let orLabel: UILabel
    let seedButton: UIButton
    let keysButton: UIButton
    
    required init() {
        seedButton = PrimaryButton(title: "Recover from seed")
        keysButton = PrimaryButton(title: "Recover from keys")
        orLabel = UILabel()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        orLabel.textAlignment = .center
        addSubview(seedButton)
        addSubview(keysButton)
        addSubview(orLabel)
    }
    
    override func configureConstraints() {
        seedButton.snp.makeConstraints { make in
            make.bottom.equalTo(orLabel.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        keysButton.snp.makeConstraints { make in
            make.top.equalTo(orLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        orLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
        }
    }
}
