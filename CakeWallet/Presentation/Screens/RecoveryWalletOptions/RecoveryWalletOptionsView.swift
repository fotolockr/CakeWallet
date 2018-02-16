//
//  RecoveryWalletOptions.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 14.02.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import UIKit

final class RecoveryWalletOptionsView: BaseView {
    let orLabel: UILabel
    let seedButton: UIButton
    let keysButton: UIButton
    
    required init() {
        seedButton = PrimaryButton(title: "Recovery from seed")
        keysButton = PrimaryButton(title: "Recovery from keys")
        orLabel = UILabel(font: .avenirNextMedium(size: 17))
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
