//
//  SummaryViewController.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

final class DashboardViewController: BaseViewController<DashboardView>,
                                     UITableViewDelegate,
                                     UIViewControllerTransitioningDelegate,
                                     UITableViewDataSource,
                                     ModalPresentaly {
    private static let transactionLimit = 5
    var presentSettingsScreen: VoidEmptyHandler
    var presentTransactionsList: VoidEmptyHandler
    var presentTransactionDetails: ((TransactionDescription) -> Void)?
    private let wallet: WalletProtocol
    private let account: Account
    private let rateTicker: RateTicker
    private var transactions: TransactionHistory
    private var _transactions: [TransactionDescription] {
        didSet {
            if oldValue != _transactions {
                contentView.showAllTransactionsButton.isHidden = DashboardViewController.transactionLimit > _transactions.count
                contentView.tableView.reloadData()
            }
        }
    }
    
    init(account: Account, wallet: WalletProtocol, rateTicker: RateTicker) {
        self.account = account
        self.wallet = wallet
        self.rateTicker = rateTicker
        self.transactions = EmptyTransactionHistory()
        _transactions = []
        super.init()
    }
    
    override func configureDescription() {
        title = "Dashboard"
        tabBarItem.image = UIImage(named: "monero-logo-335.png")?.resized(to: CGSize(width: 32, height: 32))
        tabBarItem.title = "Dashboard"
    }
    
    override func configureBinds() {
        let onStatusButtonGesture = UITapGestureRecognizer(target: self, action: #selector(reconnect))
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TransactionUITableViewCell.self, forCellReuseIdentifier: TransactionUITableViewCell.identifier)
        contentView.statusViewContainer.iconView.imageView.isUserInteractionEnabled = true
        contentView.statusViewContainer.iconView.imageView.addGestureRecognizer(onStatusButtonGesture)
        contentView.showAllTransactionsButton.addTarget(self, action: #selector(showAllTransactionsList), for: .touchUpInside)
        contentView.showAllTransactionsButton.isHidden = true
        
        wallet.observe { [weak self] change, wallet in
            switch change {
            case let .changedStatus(status):
                self?.setStatus(status)
                self?.setTransaction(wallet.transactionHistory().transactions)
            case let .changedUnlockedBalance(unlockedBalance):
                self?.contentView.balanceViewContainer.contentView.balance = wallet.balance.formatted()
                self?.contentView.balanceViewContainer.contentView.unlockedBalance = unlockedBalance.formatted()
                self?.updateRateBalance()
            case let .changedBalance(balance):
                self?.contentView.balanceViewContainer.contentView.balance = balance.formatted()
                self?.contentView.balanceViewContainer.contentView.unlockedBalance = wallet.unlockedBalance.formatted()
                self?.setTransaction(wallet.transactionHistory().transactions)
                self?.updateRateBalance()
            case .reset:
                self?.setStatus(wallet.status)
                self?.contentView.balanceViewContainer.contentView.balance = wallet.balance.formatted()
                self?.contentView.balanceViewContainer.contentView.unlockedBalance = wallet.unlockedBalance.formatted()
                
                if wallet.isWatchOnly {
                    self?.navigationItem.title = "\(wallet.name) (watch-only)"
                } else {
                    self?.navigationItem.title = wallet.name
                }
                
                self?.setTransaction(wallet.transactionHistory().transactions)
                self?.updateRateBalance()
            default:
                break
            }
        }
        
        rateTicker.add { [weak self] currency, _ in
            self?.setCurrency(currency)
            self?.updateRateBalance()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrency(account.currency)
        updateRateBalance()
        setStatus(wallet.status)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _transactions.count > DashboardViewController.transactionLimit ? DashboardViewController.transactionLimit : _transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = _transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        
        if let cell = cell as? TransactionDescription.CellType {
            cell.short()
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = _transactions[indexPath.row]
        presentTransactionDetails?(transaction)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let nav = UINavigationController(rootViewController: presented)
        let halfSizePresentationController = HalfSizePresentationController(presentedViewController: nav, presenting: presenting)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: halfSizePresentationController, action: #selector(halfSizePresentationController.hide))
        nav.topViewController?.navigationItem.leftBarButtonItem = doneButton
        return halfSizePresentationController
    }
    
    @objc
    private func showAllTransactionsList() {
        presentTransactionsList?()
    }
    
    private func setTransaction(_ transactions: [TransactionDescription]) {
        _transactions = transactions.sorted(by: {  $0.date > $1.date })
    }
    
    private func setCurrency(_ currency: Currency) {
        contentView.balanceViewContainer.contentView.setCurrency(currency)
    }
    
    private func updateRateBalance() {
        let rateBalance = convertXMRtoUSD(amount: wallet.balance.formatted(), rate: rateTicker.rate)
        contentView.balanceViewContainer.contentView.alternativeBalance = rateBalance
    }
    
    private func setStatus(_ status: NetworkStatus) {
        self.contentView.statusViewContainer.contentView.update(status: status)
        let iconView = contentView.statusViewContainer.iconView

        switch status {
        case .connecting, .startUpdating, .updating(_):
            if !iconView.isRoutating {
                iconView.rotate()
            }
        case .failedConnection(_), .failedConnectionNext, .notConnected:
            contentView.statusViewContainer.iconView.pulsate()
            contentView.statusViewContainer.iconView.stopRotate()
        default:
            iconView.stopRotate()
        }
    }
    
    @objc
    private func onPresentSettings() {
        presentSettingsScreen?()
    }
    
    @objc
    private func reconnect() {
        let alert = UIAlertController(title: "Reconnect ?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let connectionSettings = self?.account.connectionSettings else {
                return
            }
            let __alert = UIAlertController(title: nil, message: "Connecting", preferredStyle: .alert)
            self?.present(__alert, animated: true)
            self?.wallet.connect(withSettings: connectionSettings, updateState: true)
                .then { _ -> Void in
                    __alert.dismiss(animated: true)
                }.catch { error in
                    __alert.dismiss(animated: true) {
                        print(error)
                        let _alert = UIAlertController(title: "Connection problems", message: "Cannot connect to remote node. Please switch to another.", preferredStyle: .alert)
                        _alert.modalPresentationStyle = .overFullScreen
                        let switchAction = UIAlertAction(title: "Switch", style: .default) { _ in
                            let nodeSettingsVC = try! container.resolve() as NodesListViewController
                            nodeSettingsVC.modalPresentationStyle = .overFullScreen
                            let navController = UINavigationController(rootViewController: nodeSettingsVC)
                            self?.present(navController, animated: true)
                        }
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                        _alert.addAction(switchAction)
                        _alert.addAction(cancelAction)
                        self?.present(_alert, animated: true)
                    }
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showWarningOnReceive() {
        UIAlertController.showInfo(
            message: "Do not send XMR to this address until the update is complete.\nPlease wait.",
            presentOn: self)
    }
}
