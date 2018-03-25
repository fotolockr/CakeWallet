//
//  AccountsListView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import SnapKit

final class WalletsView: BaseView {
    let table: UITableView
    
    required init() {
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.backgroundColor = .whiteSmoke
        table.rowHeight = 50
        table.sectionHeaderHeight = 50
        table.tableFooterView = UIView()
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
