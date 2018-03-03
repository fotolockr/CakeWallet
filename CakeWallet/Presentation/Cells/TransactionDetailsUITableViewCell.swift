//
//  TransactionDetailsUITableViewCell.swift
//  Wallet
//
//  Created by Cake Technologies 12/6/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class TransactionDetailsUITableViewCell: UITableViewCell {
    let titleLabel: UILabel
    let valueLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(font: .avenirNextDemiBold(size: 17))
        valueLabel = UILabel(font: .avenirNextMedium(size: 14))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        addSubview(titleLabel)
        addSubview(valueLabel)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(50)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalTo(titleLabel.snp.trailing).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        needsUpdateConstraints()
    }
}
