//
//  Disclaimer.swift
//  CakeWallet
//
//  Created by Cake Technologies 24.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit
import WebKit

final class DisclaimerView: BaseView {
    let textView: UITextView
    let acceptButton: UIButton
    let cancelButton: UIButton
    
    required init() {
        textView = UITextView()
        acceptButton = UIButton()
        cancelButton = UIButton()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        acceptButton.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        cancelButton.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        acceptButton.setTitleColor(.black, for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        acceptButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.textAlignment = .center
        acceptButton.setTitle("Accept", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        addSubview(textView)
        addSubview(acceptButton)
        addSubview(cancelButton)
    }
    
    override func configureConstraints() {
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalTo(acceptButton.snp.top)
            make.trailing.equalToSuperview()
        }

        acceptButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(50)
        }

        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(acceptButton.snp.trailing)
            make.height.equalTo(50)
        }
    }
}
