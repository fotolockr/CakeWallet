//
//  OverviewView.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import SnapKit
import FontAwesome_swift

final class DashboardView: BaseView {
    static let tableViewHeaderHeight: CGFloat = 270
    let tableView: UITableView
    let statusViewContainer: IconContainerView<StatusViewImpl>
    let tableViewHeader: UIView
    let innerTableViewHeader: UIView
    let balanceViewContainer: IconImageContainerView<BalanceView>
    let exchangeButton: UIView
    let buyButton: UIView
    let showAllTransactionsButton: UIButton
    
    required init() {
        tableView = UITableView()
        statusViewContainer = IconContainerView<StatusViewImpl>(contentView: StatusViewImpl(), fontAwesomeIcon: .refresh)
        tableViewHeader = UIView()
        innerTableViewHeader = UIView()
        balanceViewContainer = IconImageContainerView<BalanceView>(
            contentView: BalanceView(),
            iconImage: UIImage(named: "monero-logo-335.png")!.resized(to: CGSize(width: 64, height: 64)))
        exchangeButton = IconView(fontAwesomeIcon: .exchange)
        buyButton = IconView(fontAwesomeIcon: .shoppingCart)
        showAllTransactionsButton = SecondaryButton(title: "Show all")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        tableViewHeader.backgroundColor = .clear
        tableViewHeader.addSubview(innerTableViewHeader)
        innerTableViewHeader.layer.masksToBounds = true
        innerTableViewHeader.layer.cornerRadius = 10
        innerTableViewHeader.backgroundColor = .white
        innerTableViewHeader.addSubview(statusViewContainer)
        innerTableViewHeader.addSubview(balanceViewContainer)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .whiteSmoke
        tableView.separatorStyle = .none
        tableView.tableHeaderView = tableViewHeader
        tableView.sectionHeaderHeight = 50
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 75, height: 75)))
        tableView.tableFooterView?.addSubview(showAllTransactionsButton)
        addSubview(tableView)
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
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        balanceViewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
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
        
        showAllTransactionsButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}
