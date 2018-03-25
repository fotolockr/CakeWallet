//
//  SettingsView.swift
//  Wallet
//
//  Created by Cake Technologies 01.11.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class SettingsView: BaseView {
    let table: UITableView
    let footerLabel: UILabel
    
    required init() {
        table = UITableView(frame: .zero)
        footerLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 100, height: 100)))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        footerLabel.font = .avenirNextMedium(size: 15)
        table.tableFooterView = footerLabel
        table.backgroundColor = .clear
        backgroundColor = .whiteSmoke
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
