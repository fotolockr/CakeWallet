//
//  NodesListViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 05.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class NodesListViewController: BaseViewController<NodesListView>, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Property injections
    
    var presentNewNodeScreen: (() -> Void)?
    
    private var account: AccountSettingsConfigurable
    private var wallet: WalletProtocol
    private var currentNodeSettings: ConnectionSettings
    private(set) var nodesList: NodesList
    
    convenience init(account: AccountImpl, nodesList: NodesList) {
        self.init(account: account, wallet: account.currentWallet, nodesList: nodesList)
    }
    
    init(account: AccountSettingsConfigurable, wallet: WalletProtocol, nodesList: NodesList) {
        self.account = account
        self.nodesList = nodesList
        self.wallet = wallet
        self.currentNodeSettings = ConnectionSettings.loadSavedSettings()
        super.init()
    }
    
    override func configureBinds() {
        title = "Nodes"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onPresentNewNodeScreen))
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        navigationItem.rightBarButtonItems = [addButton, resetButton]
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [ConnectionSettings.self])
        contentView.autoReconnectSwitchView.addTarget(self, action: #selector(onAutoSwitchNodeChange), for: .valueChanged)
        
        if self.navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))
            navigationItem.leftBarButtonItem = closeButton
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.currentNodeSettings = ConnectionSettings.loadSavedSettings()
            self?.contentView.table.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.autoReconnectSwitchView.isOn = account.autoSwitchNode
        contentView.table.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = nodesList[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath) as? NodeUITableViewCell else {
            return UITableViewCell()
        }
        
        if item == currentNodeSettings {
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .lightGreen
            cell.selectionStyle = .none
            cell.statusImageView.isHidden = true
        } else {
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
            
            if cell.statusImageView.isHidden {
                cell.statusImageView.isHidden = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nodesList[indexPath.row] != currentNodeSettings {
            let nodeSettings = nodesList[indexPath.row]
            let alert = UIAlertController(
                title: "Change node",
                message: "Are you sure that you want to change node to selected node ?",
                preferredStyle: .alert)
            let ok = UIAlertAction(title: "Change", style: .default) { [weak self] _ in
                self?.changeCurrentNode(to: nodeSettings)
                self?.contentView.table.deselectRow(at: indexPath, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.contentView.table.deselectRow(at: indexPath, animated: true)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard nodesList[indexPath.row] != currentNodeSettings else {
            return []
        }

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { [weak self] (_, indexPath) in
            self?.removeNode(at: indexPath)
        }
        
        return [deleteAction]
    }
    
    @objc
    private func onPresentNewNodeScreen() {
        presentNewNodeScreen?()
    }
    
    @objc
    private func closeAction() {
        dismiss(animated: true)
    }
    
    @objc
    private func onAutoSwitchNodeChange() {
        account.autoSwitchNode = contentView.autoReconnectSwitchView.isOn
    }
    
    @objc
    private func reset() {
        let alert = UIAlertController(
            title: "Reset nodes list to default",
            message: "Are you sure that you want to reset nodes list to deault ?",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            do {
                let _alert = UIAlertController(
                    title: nil,
                    message: "Connecting to default node",
                    preferredStyle: .alert)
                self?.present(_alert, animated: true)
                try self?.nodesList.reset()
                let currentNodeSettings = self?.account.resetConnectionSettings()
                self?.contentView.table.reloadData()
                self?.account.change(connectionSettings: currentNodeSettings!)
                    .always {
                        self?.setCurrenctNode(settings: currentNodeSettings!)
                    }.then { _ -> Void in
                        _alert.dismiss(animated: true) {
                            if let _self = self {
                                UIAlertController.showInfo(message: "Changed and connected", presentOn: _self)
                            }
                        }
                    }.catch { error in
                        _alert.dismiss(animated: true) {
                            self?.showError(error)
                        }
                }
            } catch {
                alert.dismiss(animated: true) {
                    self?.showError(error)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func changeCurrentNode(to connectionSettings: ConnectionSettings) {
        let alert = UIAlertController.showSpinner(message: "Connecting")
        present(alert, animated: true) { [weak self] in
            self?.account.change(connectionSettings: connectionSettings)
                .then { _ -> Void in
                    alert.dismiss(animated: true) {
                        self?.setCurrenctNode(settings: connectionSettings)
                        
                        if let this = self {
                            UIAlertController.showInfo(message: "Changed and connected", presentOn: this)
                        }
                    }
                }.catch { error in
                    alert.dismiss(animated: true) {
                        self?.showError(error)
                    }
            }
        }
    }
    
    private func removeNode(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Remove node",
            message: "Are you sure that you want to delete selected node ?",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            do {
                try self?.nodesList.remove(at: indexPath.row)
                self?.contentView.table.reloadData()
            } catch {
                self?.showError(error)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func setCurrenctNode(settings: ConnectionSettings) {
        currentNodeSettings = settings
        contentView.table.reloadData()
    }
}
