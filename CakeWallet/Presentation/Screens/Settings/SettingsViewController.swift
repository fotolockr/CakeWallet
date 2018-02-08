//
//  SettingsViewController.swift
//  Wallet
//
//  Created by Cake Technologies 01.11.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class SettingsViewController: BaseViewController<SettingsView>, UITableViewDelegate, UITableViewDataSource {
    enum SettingsSections: Int {
        case personal, wallets
    }
    
    struct SettingsCellItem: CellItem {
        let title: String
        let action: VoidEmptyHandler
        let image: UIImage?
        
        init(title: String, image: UIImage? = nil, action: VoidEmptyHandler = nil) {
            self.title = title
            self.image = image
            self.action = action
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    final class SettingsSwitchCellItem: CellItem {
        let title: String
        let image: UIImage?
        let action: ((Bool) -> Void)?
        let switchView: UISwitch
        
        init(title: String, image: UIImage? = nil, isOn: Bool, action: ((Bool) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.switchView = UISwitch()
            self.switchView.isOn = isOn
            config()
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryView = switchView
        }
        
        private func config() {
            switchView.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
        }
        
        @objc
        private func onValueChange() {
            self.action?(self.switchView.isOn)
        }
    }
    
    struct SettingsPickerCellItem<PickerItem: Stringify>: CellItem {
        let title: String
        let image: UIImage?
        let pickerOptions: [PickerItem]
        let action: ((PickerItem) -> Void)?
        private var selectedIndex: Int
        
        init(title: String, image: UIImage? = nil, pickerOptions: [PickerItem], selectedAtIndex: Int, action: ((PickerItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.pickerOptions = pickerOptions
            self.selectedIndex = selectedAtIndex
        }
        
        func setup(cell: SettingsPickerUITableViewCell<PickerItem>) {
            cell.configure(title: title, pickerOptions: pickerOptions, selectedOption: selectedIndex, action: action)
            cell.imageView?.image = image
        }
    }
    
    // MARK: Property injections
    
    var presentChangePasswordScreen: VoidEmptyHandler
    var presentNodeSettingsScreen: VoidEmptyHandler
    var presentWalletsScreen: VoidEmptyHandler
    
    
    private var sections: [SettingsSections: [CellAnyItem]]
    private var accountSettings: AccountSettingsConfigurable
    
    init(accountSettings: AccountSettingsConfigurable) {
        self.accountSettings = accountSettings
        self.sections = [.personal: [], .wallets: []]
        super.init()
    }

    override func configureBinds() {
        title = "Settings"
        contentView.table.register(items: [SettingsCellItem.self, SettingsPickerCellItem<TransactionPriority>.self])
        contentView.table.delegate = self
        contentView.table.dataSource = self
        
        let biometricAuthSwitcher = SettingsSwitchCellItem(
            title: "Allow biometric authentication",
            image: UIImage.fontAwesomeIcon(
                name: .idCard,
                textColor: UIColor(hex: 0x2D93AD), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            isOn: accountSettings.isBiometricalAuthAllow,
            action: { [weak self] isOn in
                self?.accountSettings.isBiometricalAuthAllow = isOn
        })
        
        let rememberPasswordSwitcher = SettingsSwitchCellItem(
            title: "Remember pin",
            image: UIImage.fontAwesomeIcon(
                name: .eye,
                textColor: UIColor(hex: 0x2D93AD), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            isOn: accountSettings.isPasswordRemembered) { [weak self] isOn in
                self?.accountSettings.isPasswordRemembered = isOn
        }
        
        let options: [TransactionPriority] = [.slow, .default, .fast, .fastest]
        
        let feePriorityPicker = SettingsPickerCellItem<TransactionPriority>(
            title: "Fee priority",
            image: UIImage.fontAwesomeIcon(
                name: .flag,
                textColor: UIColor(hex: 0x2D93AD), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            pickerOptions: options,
            selectedAtIndex: options.index(of: accountSettings.transactionPriority) ?? 0) { [weak self] pickedItem in
                self?.accountSettings.transactionPriority = pickedItem
        }
        
        let changePin = SettingsCellItem(
            title: "Change pin",
            image: UIImage.fontAwesomeIcon(
                name: .unlockAlt,
                textColor: UIColor(hex: 0x2D93AD), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            action: { [weak self] in
                self?.presentChangePasswordScreen?()
        })
        
        let nodeSettings = SettingsCellItem(
            title: "Daemon settings",
            image: UIImage.fontAwesomeIcon(
                name: .terminal,
                textColor: UIColor(hex: 0x2D93AD), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            action: { [weak self] in
                self?.presentNodeSettingsScreen?()
        })
        
        sections[.personal] = [
            changePin,
            nodeSettings,
            biometricAuthSwitcher,
            rememberPasswordSwitcher,
            feePriorityPicker
        ]
        
        sections[.wallets] = [SettingsCellItem(
            title: "Wallets",
            image: UIImage.fontAwesomeIcon(
                name: .addressBook,
                textColor: UIColor(hex: 0xFDE74C), // FIX-ME: Unnamed constant
                size: CGSize(width: 32, height: 32)),
            action: { [weak self] in
                self?.presentWalletsScreen?()
        })]
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let section = SettingsSections(rawValue: section),
            let count = sections[section]?.count else {
                return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] else {
                return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSections(rawValue: section) else {
            return nil
        }
        
        let view = UIView(frame:
            CGRect(
                origin: .zero,
                size: CGSize(width: tableView.frame.width, height: tableView.sectionHeaderHeight)))
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: view.frame.width - 20, height: view.frame.height)))
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        view.backgroundColor = .clear
        view.addSubview(titleLabel)
        
        switch section {
        case .personal:
            titleLabel.text = "Personal" // FIX-ME: Unnamed constant
        case .wallets:
            titleLabel.text = "Wallets" // FIX-ME: Unnamed constant
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] as? SettingsCellItem else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
        }
        
        item.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
