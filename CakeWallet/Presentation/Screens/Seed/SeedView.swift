//
//  MnemoticView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class SeedView: BaseView {
    let nameLabel: UILabel
    let seedTextView: UITextView
    
    required init() {
        nameLabel = UILabel(font: .avenirNextBold(size: 24))
        seedTextView = UITextView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nameLabel.textAlignment = .center
        seedTextView.textAlignment = .center
        seedTextView.font = .avenirNextMedium(size: 15)
        seedTextView.backgroundColor = .clear
        seedTextView.isEditable = false
        seedTextView.isScrollEnabled = false
        seedTextView.isUserInteractionEnabled = true
        addSubview(nameLabel)
        addSubview(seedTextView)
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
    }
}
