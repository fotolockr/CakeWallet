//
//  WalletKeysView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 15.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class WalletKeyView: BaseView {
    let nameLabel: UILabel
    let table: UITableView
    
    required init() {
        nameLabel = UILabel(font: .avenirNextBold(size: 24))
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.rowHeight = 75
        table.allowsSelection = false
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        addSubview(table)
    }
    
    override func configureConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        table.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
