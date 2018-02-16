//
//  NodeSettingsViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies 10.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class NodeSettingsViewController: BaseViewController<NodeSettingsView> {
    private let account: AccountSettingsConfigurable
    private var connectionSettings: ConnectionSettings {
        return account.connectionSettings
    }
    
    init(account: AccountSettingsConfigurable) {
        self.account = account
        super.init()
    }
    
    override func configureBinds() {
        title = "Daemon settings"
        setSettings(connectionSettings)
        contentView.connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        contentView.resetSettings.addTarget(self, action: #selector(onResetSetting), for: .touchUpInside)
        contentView.descriptionLabel.text = "If you don't know what this setting is for, please don't change the settings."
    }
    
    private func setSettings(_ settings: ConnectionSettings) {
        setAddress()
        contentView.loginLabel.text = settings.login
        contentView.passwordLabel.text =  settings.password
    }
    
    private func setAddress() {
        let splitedUri = connectionSettings.uri.components(separatedBy: ":")
        let address = splitedUri.first ?? ""
        let port = Int(splitedUri.last ?? "") ?? 0
        
        contentView.nodeAddressLabel.text = address
        contentView.nodePortLabel.text  = "\(port)"
    }
    
    @objc
    private func onResetSetting() {
        let alert = UIAlertController(
            title: "Reset settings",
            message: "Are you sure that you want reset settings to default ?",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let settings = self?.account.resetConnectionSettings() else {
                return
            }
            
            self?.setSettings(settings)
            self?.connect()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc
    private func connect() {
        let _alert = UIAlertController.showSpinner(message: "Connection")
        present(_alert, animated: true)
        
        guard
            let address = contentView.nodeAddressLabel.text,
            let port = contentView.nodePortLabel.text else {
            return
        }
        
        let uri = "\(address):\(port)"
        
        let connectionSettings = ConnectionSettings(
            uri: uri,
            login: contentView.loginLabel.text ?? "",
            password: contentView.passwordLabel.text ?? "")
        
        account.change(connectionSettings: connectionSettings)
            .then { [weak self] in
                _alert.dismiss(animated: true) {
                    if let this = self {
                        UIAlertController.showInfo(message: "Saved and connected", presentOn: this)
                    }}
            }.catch { [weak self] error in
                _alert.dismiss(animated: true) {
                    self?.showError(error)
                }
        }
    }
}
