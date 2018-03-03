//
//  SummaryViewController.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class DashboardViewController: BaseViewController<DashboardView>,
                                     UITableViewDelegate,
                                     UIViewControllerTransitioningDelegate,
                                     UITableViewDataSource,
                                     ModalPresentaly {
    var presentSettingsScreen: VoidEmptyHandler
    var presentSendScreen: VoidEmptyHandler
    var presentReceiveScreen: VoidEmptyHandler
    var presentTransactionDetails: ((TransactionDescription) -> Void)?
    private let wallet: WalletProtocol
    private let account: CurrencySettingsConfigurable
    private let rateTicker: RateTicker
    private var transactions: TransactionHistory
    private var _transactions: [Array<TransactionDescription>.SectionOfTransactions] {
        didSet {
            if oldValue != _transactions {
                contentView.tableView.reloadData()
            }
        }
    }
    
    init(account: CurrencySettingsConfigurable, wallet: WalletProtocol, rateTicker: RateTicker) {
        self.account = account
        self.wallet = wallet
        self.rateTicker = rateTicker
        self.transactions = EmptyTransactionHistory()
        _transactions = []
        super.init()
    }
    
    override func configureBinds() {        
        let showSettingsButton = UIBarButtonItem(
            image: UIImage.fontAwesomeIcon(
                name: .cog,
                textColor: .gray,
                size: CGSize(width: 36, height: 36)),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(onPresentSettings))
        navigationItem.setRightBarButton(showSettingsButton, animated: false)
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TransactionUITableViewCell.self, forCellReuseIdentifier: TransactionUITableViewCell.identifier)
        contentView.receiveButton.addTarget(self, action: #selector(onPresentReceiveScreen), for: .touchUpInside)
        contentView.newTransactionButton.addTarget(self, action: #selector(onPresentSendScreen), for: .touchUpInside)
        
        wallet.observe { change, wallet in
            switch change {
            case let .changedStatus(status):
                self.setStatus(status)
                self._transactions = wallet.transactionHistory().transactions.toDatesSections()
            case let .changedUnlockedBalance(unlockedBalance):
                self.contentView.balanceViewContainer.contentView.unlockedBalance = unlockedBalance.formatted()
            case let .changedBalance(balance):
                self.contentView.balanceViewContainer.contentView.balance = balance.formatted()
                self._transactions = wallet.transactionHistory().transactions.toDatesSections()
                self.updateRateBalance()
            case .reset:
                self.setStatus(wallet.status)
                self.contentView.balanceViewContainer.contentView.balance = wallet.balance.formatted()
                self.contentView.balanceViewContainer.contentView.unlockedBalance = wallet.unlockedBalance.formatted()
                
                if wallet.isWatchOnly {
                    self.contentView.titleViewHeader.title = "\(wallet.name) (watch-only)"
                } else {
                    self.contentView.titleViewHeader.title = wallet.name
                }
                // FIX-ME: Unnamed constant
                self.contentView.titleViewHeader.subtitle = "Monero"
                self._transactions = wallet.transactionHistory().transactions.toDatesSections()
                self.updateRateBalance()
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
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let nav = UINavigationController(rootViewController: presented)
        let halfSizePresentationController = HalfSizePresentationController(presentedViewController: nav, presenting: presenting)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: halfSizePresentationController, action: #selector(halfSizePresentationController.hide))
        nav.topViewController?.navigationItem.leftBarButtonItem = doneButton
        return halfSizePresentationController
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
        case .connecting, .startUpdating, .updating(_), .failedConnection(_):
            if !iconView.isRoutating {
                iconView.rotate()
            }
        default:
            iconView.stopRotate()
        }
    }
    
    @objc
    private func onPresentReceiveScreen() {
        if wallet.isReadyToReceive {
            presentReceiveScreen?()
        } else {
            showWarningOnReceive()
        }
    }
    
    @objc
    private func onPresentSendScreen() {
        guard !wallet.isWatchOnly else {
            let _ = UIAlertController.showInfo(
                message: "You cannot send from a watch only wallet.",
                presentOn: self)
            return
        }
        
        presentSendScreen?()
    }
    
    @objc
    private func onPresentSettings() {
        presentSettingsScreen?()
    }
    
    private func showWarningOnReceive() {
        UIAlertController.showInfo(
            message: "Do not send XMR to this address until the update is complete.\nPlease wait.",
            presentOn: self)
    }
}
