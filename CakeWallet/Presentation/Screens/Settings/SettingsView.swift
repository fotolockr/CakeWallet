//
//  SettingsView.swift
//  Wallet
//
//  Created by FotoLockr on 01.11.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class SettingsView: BaseView {
    let table: UITableView
    
    required init() {
        table = UITableView(frame: .zero)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.sectionHeaderHeight = 50
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = .clear
        
        // FIX-ME: Unnamed constant
        
        backgroundColor = UIColor(hex: 0xF5F7F9) //UIColor(hex: 0xF7F7F2)
        addSubview(table)
    }
    
    override func configureConstraints() {
        table.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
