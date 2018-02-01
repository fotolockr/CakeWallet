//
//  TransactionDetails.swift
//  Wallet
//
//  Created by FotoLockr on 12/6/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class TransactionDetailsView: BaseView {
    let table: UITableView
    
    required init() {
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.rowHeight = 75
        table.allowsSelection = false
        addSubview(table)
    }
    
    override func configureConstraints() {
        table.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
