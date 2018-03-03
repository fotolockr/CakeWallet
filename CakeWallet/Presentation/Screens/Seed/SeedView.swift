//
//  MnemoticView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class SeedView: BaseView {
    let nameLabel: UILabel
    let seedTextView: UITextView
    let finishButton: UIButton
    
    required init() {
        nameLabel = UILabel(font: .avenirNextBold(size: 24))
        seedTextView = UITextView()
        finishButton = PrimaryButton(title: "Finish")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nameLabel.textAlignment = .center
        seedTextView.textAlignment = .center
        seedTextView.font = UIFont.avenirNextMedium(size: 17)
        seedTextView.backgroundColor = .clear
        seedTextView.isEditable = false
        seedTextView.isScrollEnabled = false
        seedTextView.isUserInteractionEnabled = true
        addSubview(nameLabel)
        addSubview(seedTextView)
        addSubview(finishButton)
    }
    
    override func configureConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        seedTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        finishButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
}
