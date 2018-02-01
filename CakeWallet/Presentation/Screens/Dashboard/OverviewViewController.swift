//
//  OverviewViewController.swift
//  Wallet
//
//  Created by Mykola Misiura on 15.10.17.
//  Copyright © 2017 Mykola Misiura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


final class SummaryViewController: BaseViewController<OverviewView>, UITableViewDataSource, UITableViewDelegate {
    private let fetchBalanceUseCase: FetchWalletBalanceUseCase
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let syncStatusUseCase: SyncStatusUseCase
    private var transactions: [Array<Transaction>.Section]
    private let disposeBag: DisposeBag
    
    init(fetchBalanceUseCase: FetchWalletBalanceUseCase,
         fetchTransactionsUseCase: FetchTransactionsUseCase,
         syncStatusUseCase: SyncStatusUseCase) {
        self.fetchBalanceUseCase = fetchBalanceUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.syncStatusUseCase = syncStatusUseCase
        self.disposeBag = DisposeBag()
        transactions = []
        super.init()
        title = "Summary"
    }
    
    override func setTabbarIcon() {
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage.fontAwesomeIcon(
                name: .tasks,
                textColor: UIColor(hex: 0x3B3561), size: CGSize(width: 32, height: 32)),
            tag: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.table.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        contentView.table.dataSource = self
        contentView.table.delegate = self
        
        let noon = Date()
        let moqTransactions: [Transaction] = [
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -1, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -2, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -3, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -2, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -3, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -2, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -3, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -4, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -5, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -6, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -7, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -1, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -2, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -1, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -4, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -3, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -1, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            ),
            SimpleTransaction(
                priority: .default,
                date: Calendar.current.date(byAdding: .day, value: -2, to: noon)!,
                formattedAmount: "00.0011",
                direction: .incoming
            )
        ]
        
        //        transactions = moqTransactions.toDatesSections()
    }
    
    override func configureBinds() {
        fetchBalanceUseCase.fetchFormattedBalance()
            .bind(to: self.contentView.balanceLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        syncStatusUseCase.currentHeight()
            .subscribe(onNext: { height in print("Current height - \(height)") })
            .addDisposableTo(disposeBag)
        
        syncStatusUseCase.blockchainHeight()
            .subscribe(onNext: { height in print("Blockchain height - \(height)") })
            .addDisposableTo(disposeBag)
        
        syncStatusUseCase.isSyncing()
            .map { !$0 }
            .bind(to: contentView.notificationView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        Observable.combineLatest(syncStatusUseCase.currentHeight(), syncStatusUseCase.blockchainHeight(), syncStatusUseCase.isSyncing())
            .subscribe(onNext: { (height, maxHeight, isSyncing) in
                self.contentView.notificationView.isHidden = !isSyncing
                guard isSyncing else { return }
                
                self.contentView.notificationTitleLabel.text = "Synchronization"
                self.contentView.notificationTextLabel.text = "New height - \(height)/\(maxHeight)"
                self.contentView.progressView.progress = Float(height) / Float(maxHeight)
            })
            .addDisposableTo(disposeBag)
        
        fetchTransactionsUseCase.fetch()
            .subscribe(onNext: { transactions in
                print("transactions")
                print(transactions)
            }, onError: { self.showError($0) })
            .addDisposableTo(disposeBag)
        
        
        
        //        walletState.isSyncing
        //            .map({ !$0 })
        //            .bind(to: self.contentView.notificationView.rx.isHidden)
        //            .addDisposableTo(disposeBag)
        //
        //        walletState.blockchainHeight
        //            .subscribe(onNext: { height in self.blockchainHeight = height })
        //            .addDisposableTo(disposeBag)
        //
        //        walletState.currentHeight
        //            .subscribe(onNext: { height in self.currentHeight = height })
        //            .addDisposableTo(disposeBag)
        //
        //        walletState.formatedBalance
        //            .bind(to: self.contentView.balanceLabel.rx.text)
        //            .addDisposableTo(disposeBag)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let date = transactions[section].date
        
        var title = ""
        
        if Calendar.current.isDateInToday(date) {
            title = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            title = "Yesterday"
        } else {
            title = dateFormatter.string(from: date)
        }
        
        return title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numOfSections = transactions.count
        
        if numOfSections > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.font = UIFont.avenirNextMedium(size: 17)
            noDataLabel.text = "Your transactions will be shown here."
            noDataLabel.textColor = .lightGray
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Rows in section - \(transactions[section].items.count)")
        return transactions[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier) as? TransactionCell,
            transactions.count >= indexPath.section,
            transactions[indexPath.section].items.count >= indexPath.row else {
                return UITableViewCell()
        }
        
        let tx = transactions[indexPath.section].items[indexPath.row]
        cell.configure(direction: tx.direction, amount: tx.formattedAmount, date: tx.date)
        return cell
    }
}

