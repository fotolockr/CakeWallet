//
//  WelcomeView.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit


// FIX-ME: Replace it

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}

final class WelcomeView: BaseView {
    let welcomeLabel: UILabel
    let welcomeSubtitleLabel: UILabel
    let descriptionTextView: UITextView
    let startButton: UIButton
    
    required init() {
        welcomeLabel = UILabel(font: .avenirNextMedium(size: 64))
        welcomeSubtitleLabel = UILabel(font: .avenirNextMedium(size: 32))
        descriptionTextView = UITextView()
        startButton = PrimaryButton(title: "Next")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionTextView.font = .avenirNextMedium(size: 17)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
        welcomeSubtitleLabel.numberOfLines = 0
        addSubview(welcomeSubtitleLabel)
        addSubview(welcomeLabel)
        addSubview(descriptionTextView)
        addSubview(startButton)
    }
    
    override func configureConstraints() {
        welcomeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(50)
        }
        
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(welcomeLabel.snp.bottom)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(welcomeSubtitleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-25)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(50)
        }
    }
}
