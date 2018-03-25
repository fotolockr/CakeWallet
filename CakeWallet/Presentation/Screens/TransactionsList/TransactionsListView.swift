//
//  TransactionsListView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 09.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class TransactionsListView: BaseView {
    let tableView: UITableView
    
    required init() {
        tableView = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        tableView.sectionHeaderHeight = 50
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .whiteSmoke
        tableView.separatorStyle = .none
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
