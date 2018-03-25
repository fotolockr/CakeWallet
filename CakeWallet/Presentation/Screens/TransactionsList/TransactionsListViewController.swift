//
//  TransactionsListViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 09.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class TransactionsListViewController: BaseViewController<TransactionsListView>, UITableViewDelegate, UITableViewDataSource {
 
    // MARK: Properties inject
    
    var presentTransactionDetails: ((TransactionDescription) -> Void)?
    
    private let wallet: WalletProtocol
    private var transactions: TransactionHistory
    private var _transactions: [Array<TransactionDescription>.SectionOfTransactions] {
        didSet {
            if oldValue != _transactions {
                contentView.tableView.reloadData()
            }
        }
    }
    
    init(wallet: WalletProtocol) {
        self.wallet = wallet
        self.transactions = EmptyTransactionHistory()
        _transactions = []
        super.init()
    }
    
    override func configureDescription() {
        title = "Transactions"
    }
    
    override func configureBinds() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TransactionUITableViewCell.self, forCellReuseIdentifier: TransactionUITableViewCell.identifier)
        
        wallet.observe { [weak self] change, wallet in
            switch change {
            case .changedStatus(_):
                self?._transactions = wallet.transactionHistory().transactions.toDatesSections()
            case .changedBalance(_):
                self?._transactions = wallet.transactionHistory().transactions.toDatesSections()
            default:
                break
            }
        }
        
        _transactions = wallet.transactionHistory().transactions.toDatesSections()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _transactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _transactions[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = _transactions[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(font: .avenirNextMedium(size: 19))
        let title: String
        let date = _transactions[section].date
        
        if Calendar.current.isDateInToday(date) {
            title = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            title = "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            title = dateFormatter.string(from: date)
        }
        
        label.text = title
        label.textColor = UIColor(hex: 0x303030) // FIX-ME: Unnamed constant
        view.backgroundColor = tableView.backgroundColor
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = _transactions[indexPath.section].items[indexPath.row]
        presentTransactionDetails?(transaction)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
