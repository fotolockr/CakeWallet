//
//  OverviewView.swift
//  Wallet
//
//  Created by FotoLockr on 15.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift

final class DashboardView: BaseView {
    static let tableViewHeaderHeight: CGFloat = 365
    let tableView: UITableView
    let statusViewContainer: IconContainerView<StatusViewImpl>
    let tableViewHeader: UIView
    let innerTableViewHeader: UIView
    let newTransactionButton: UIButton
    let balanceViewContainer: IconContainerView<BalanceView>
    let receiveButton: UIButton
    let titleViewHeader: (TitledView & UIView)

    required init() {
        tableView = UITableView()
        statusViewContainer = IconContainerView<StatusViewImpl>(contentView: StatusViewImpl(), fontAwesomeIcon: .refresh)
        tableViewHeader = UIView()
        innerTableViewHeader = UIView()
        let _newTransactionButton = SecondaryButton(title: "Send") //UIButton(type: .custom)
        newTransactionButton = _newTransactionButton
        _newTransactionButton.setLeftImage(
            UIImage.fontAwesomeIcon(
                name: .paperPlane,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        balanceViewContainer = IconContainerView<BalanceView>(contentView: BalanceView(), fontAwesomeIcon: .areaChart)
        let _receiveButton = SecondaryButton(title: "Receive")
        receiveButton = _receiveButton
        _receiveButton.setLeftImage(
            UIImage.fontAwesomeIcon(
                name: .inbox,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        titleViewHeader = StandartTitledView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        tableViewHeader.backgroundColor = .clear
        tableViewHeader.addSubview(innerTableViewHeader)
        innerTableViewHeader.backgroundColor = .white
        innerTableViewHeader.addSubview(statusViewContainer)
        innerTableViewHeader.addSubview(balanceViewContainer)
        innerTableViewHeader.addSubview(receiveButton)
        innerTableViewHeader.addSubview(titleViewHeader)
        innerTableViewHeader.addSubview(newTransactionButton)
        
        tableView.sectionHeaderHeight = 25
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: 0xF5F7F9) // FIX-ME: Unnamed constant
        tableView.separatorStyle = .none
        tableView.tableHeaderView = tableViewHeader
        tableView.sectionHeaderHeight = 50
       
        addSubview(tableView)
        
//        bringSubview(toFront: newTransactionButton)
//        newTransactionButton.backgroundColor = UIColor(hex: 0x006494)
//        newTransactionButton.layer.masksToBounds = true
//        newTransactionButton.layer.cornerRadius = 28
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        innerTableViewHeader.layer.shadowColor = UIColor.lightGray.cgColor
        innerTableViewHeader.layer.shadowOffset = CGSize(width: 1, height: 1)
        innerTableViewHeader.layer.shadowRadius = 5
        innerTableViewHeader.layer.shadowOpacity = 0.3
    }
    
    override func configureConstraints() {
        tableView.tableHeaderView?.snp.makeConstraints { make in
            make.height.equalTo(DashboardView.tableViewHeaderHeight)
            make.leading.equalToSuperview()
            make.width.equalTo(tableView.snp.width)
        }
        
        innerTableViewHeader.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        titleViewHeader.snp.makeConstraints { make in
            make.top.equalTo(receiveButton.snp.bottom)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(titleViewHeader)
            make.trailing.equalTo(receiveButton.snp.leading).offset(-10)
        }
        
        receiveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(115)
            make.height.equalTo(35)
        }
        
        balanceViewContainer.snp.makeConstraints { make in
            make.top.equalTo(titleViewHeader.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(balanceViewContainer.snp.height)
        }

        statusViewContainer.snp.makeConstraints { make in
            make.top.equalTo(balanceViewContainer.snp.bottom).offset(25)
            make.leading.equalTo(balanceViewContainer.snp.leading)
            make.trailing.equalTo(balanceViewContainer.snp.trailing)
            make.height.equalTo(45)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        newTransactionButton.snp.makeConstraints { make in
            make.top.equalTo(receiveButton.snp.top)
            make.trailing.equalTo(receiveButton.snp.leading).offset(-10)
            make.width.equalTo(115)
            make.height.equalTo(35)
//            make.bottom.equalToSuperview().offset(-25)
//            make.trailing.equalToSuperview().offset(-15)
//            make.height.equalTo(56)
//            make.width.equalTo(56)
        }
    }
}
