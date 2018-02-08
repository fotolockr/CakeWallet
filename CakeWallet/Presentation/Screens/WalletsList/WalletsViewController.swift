//
//  AccountsListViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

final class WalletsViewController: BaseViewController<WalletsView>, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Property injections
    
    var presentLoadWalletScreen: ((WalletIndex) -> Void)?
    var presentSeedWalletScreen: ((WalletIndex) -> Void)?
    var presentRemoveWalletScreen: ((WalletIndex) -> Void)?
    var presentNewWalletScreen: (() -> Void)?
    
    private var cachedHeaders: [WalletType: UIView]
    private var walletsList: WalletsList
    private let account: Account
    
    init(account: Account) {
        self.account = account
        cachedHeaders = [WalletType: UIView]()
        walletsList = [:]
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        account.walletsList()
            .then { [weak self] walletsList -> Void in
                self?.walletsList = walletsList
                self?.contentView.table.reloadData()
            }
    }
    
    override func configureBinds() {
        title = "Wallets"
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [WalletDescription.self])
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return walletsList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletsList[section].value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = walletsList[indexPath.section].value[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath) as? WalletDescription.CellType else {
                return UITableViewCell()
        }

        if item.name == account.currentWalletName {
            cell.textLabel?.textColor = .white
            cell.contentView.backgroundColor = .lightGreen
        } else {
            cell.textLabel?.textColor = .black
            cell.contentView.backgroundColor = .clear
        }

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard walletsList.count > 0 else {
            return nil
        }

        let walletType = walletsList[section].key

        if let header = cachedHeaders[walletType] {
            return header
        }

        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: tableView.sectionHeaderHeight)))
        view.backgroundColor = .groupTableViewBackground
        let titleLabel = UILabel(font: UIFont.avenirNextHeavy(size: 17))
        titleLabel.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: view.frame.width - 45, height: 35))
        titleLabel.text = "\(walletType.stringify()) wallets"
        let addButton =  PrimaryButton(title: "Add")
        addButton.frame = CGRect(origin: CGPoint(x: view.frame.width - 110, y: 7), size: CGSize(width: 100, height: 35))
        addButton.addTarget(self, action: #selector(onPresentNewWalletScreen), for: .touchUpInside)
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        cachedHeaders[walletType] = view

        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMenuForWallet(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard getWallet(at: indexPath).name != account.currentWalletName else {
            return nil
        }

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, indexPath) in
            self.removeWallet(at: indexPath)
        }

        return [deleteAction]
    }
    
    @objc
    private func onPresentNewWalletScreen() {
        presentNewWalletScreen?()
    }

    private func showMenuForWallet(atIndexPath indexPath: IndexPath) {
        let wallet = getWallet(at: indexPath)
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.contentView.table.deselectRow(at: indexPath, animated: true)
        }
        let showSeecAction = UIAlertAction(title: "Show seed", style: .default) { _ in
            self.presentSeedWalletScreen?(wallet.index)
        }

        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.addAction(showSeecAction)
        alertViewController.addAction(cancelAction)

        if wallet.name != account.currentWalletName {
            let loadWalletAction = UIAlertAction(title: "Load wallet", style: .default) { _ in
                self.presentLoadWalletScreen?(wallet.index)
            }

            alertViewController.addAction(loadWalletAction)
        }

        present(alertViewController, animated: true)
    }

    private func removeWallet(at indexPath: IndexPath) {
        let wallet = getWallet(at: indexPath)
        presentRemoveWalletScreen?(wallet.index)
    }

    private func getWallet(at indexPath: IndexPath) -> WalletDescription {
        return  walletsList[indexPath.section].value[indexPath.row]
    }
}
