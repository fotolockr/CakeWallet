//
//  WalletUITableCell.swift
//  Wallet
//
//  Created by Cake Technologies 24.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class WalletUITableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureConstraints() {
        textLabel?.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(name: String) {
        textLabel?.text = name
    }
}
