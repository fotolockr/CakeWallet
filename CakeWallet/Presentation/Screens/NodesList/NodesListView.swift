//
//  NodesListView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 05.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit
import SnapKit

final class NodesListView: BaseView {
    let table: UITableView
    let autoReconnectSwitchView: UISwitch
    let autoReconnectLabel: UILabel
    
    required init() {
        table = UITableView()
        autoReconnectSwitchView = UISwitch()
        autoReconnectLabel = UILabel(font: .avenirNextMedium(size: 15))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.backgroundColor = .whiteSmoke
        table.rowHeight = 50
        table.sectionHeaderHeight = 50
        table.tableFooterView = UIView()
        autoReconnectLabel.text = "Auto switch node"
        addSubview(table)
        addSubview(autoReconnectSwitchView)
        addSubview(autoReconnectLabel)
        bringSubview(toFront: autoReconnectLabel)
        bringSubview(toFront: autoReconnectSwitchView)
    }
    
    override func configureConstraints() {
        table.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(autoReconnectLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        autoReconnectSwitchView.snp.makeConstraints { make in
            make.centerY.equalTo(autoReconnectLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        autoReconnectLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(autoReconnectSwitchView.snp.leading).offset(-15)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
    }
}
