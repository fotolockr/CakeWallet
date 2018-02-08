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
        setAddress()
        contentView.loginLabel.text = connectionSettings.login
        contentView.passwordLabel.text =  connectionSettings.password
        contentView.connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        contentView.descriptionLabel.text = "If you don't know what this setting is for, please don't change the settings."
    }
    
    private func setAddress() {
        let splitedUri = connectionSettings.uri.components(separatedBy: ":")
        let address = splitedUri.first ?? ""
        let port = Int(splitedUri.last ?? "") ?? 0
        
        contentView.nodeAddressLabel.text = address
        contentView.nodePortLabel.text  = "\(port)"
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
