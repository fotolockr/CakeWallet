//
//  SettingsViewController.swift
//  Wallet
//
//  Created by Cake Technologies 01.11.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

final class SettingsViewController: BaseViewController<SettingsView>, UITableViewDelegate, UITableViewDataSource {
    enum SettingsSections: Int {
        case donation, wallets, personal, advanced, contactUs
    }
    
    struct SettingsTextViewCellItem: CellItem {
        let attributedString: NSAttributedString
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
        
        func setup(cell: UITableViewCell) {
            let textView = UITextView()
            textView.isEditable = false
            textView.attributedText = attributedString
            cell.contentView.addSubview(textView)
            cell.accessoryType = .none
            
            textView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
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
        let onFinish: ((PickerItem) -> Void)?
        private var selectedIndex: Int
        
        init(title: String,
             image: UIImage? = nil,
             pickerOptions: [PickerItem],
             selectedAtIndex: Int,
             action: ((PickerItem) -> Void)? = nil,
             onFinish: ((PickerItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.pickerOptions = pickerOptions
            self.selectedIndex = selectedAtIndex
            self.onFinish = onFinish
        }
        
        func setup(cell: SettingsPickerUITableViewCell<PickerItem>) {
            cell.configure(title: title, pickerOptions: pickerOptions, selectedOption: selectedIndex, action: action)
            cell.imageView?.image = image
            cell.onFinish = onFinish
        }
    }
    
    // MARK: Property injections
    
    var presentChangePasswordScreen: VoidEmptyHandler
    var presentNodeSettingsScreen: VoidEmptyHandler
    var presentWalletsScreen: VoidEmptyHandler
    var presentWalletKeys: VoidEmptyHandler
    var presentWalletSeed: VoidEmptyHandler
    var presentDonation: VoidEmptyHandler
    
    private var sections: [SettingsSections: [CellAnyItem]]
    private var accountSettings: AccountSettingsConfigurable & CurrencySettingsConfigurable
    private var showSeedIsAllow: Bool
    
    init(accountSettings: AccountSettingsConfigurable & CurrencySettingsConfigurable, showSeedIsAllow: Bool) {
        self.accountSettings = accountSettings
        self.showSeedIsAllow = showSeedIsAllow
        self.sections = [.wallets: [], .personal: []]
        super.init()
    }
    
    override func configureDescription() {
        title = "Settings"
        updateTabBarIcon(name: .cog)
    }

    override func configureBinds() {
        contentView.table.register(items: [SettingsCellItem.self, SettingsPickerCellItem<TransactionPriority>.self, SettingsPickerCellItem<Currency>.self])
        contentView.table.delegate = self
        contentView.table.dataSource = self
        
        if
            let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            contentView.footerLabel.text = "Version \(version)"
        }
        
        let biometricAuthSwitcher = SettingsSwitchCellItem(
            title: "Allow biometric authentication",
            isOn: accountSettings.isBiometricalAuthAllow,
            action: { [weak self] isOn in
                self?.accountSettings.isBiometricalAuthAllow = isOn
        })
        
        let rememberPasswordSwitcher = SettingsSwitchCellItem(
            title: "Remember pin",
            isOn: accountSettings.isPasswordRemembered) { [weak self] isOn in
                self?.accountSettings.isPasswordRemembered = isOn
        }
        
        let options: [TransactionPriority] = [.slow, .default, .fast, .fastest]
        
        let feePriorityPicker = SettingsPickerCellItem<TransactionPriority>(
            title: "Fee priority",
            pickerOptions: options,
            selectedAtIndex: options.index(of: accountSettings.transactionPriority) ?? 0) { [weak self] pickedItem in
                self?.accountSettings.transactionPriority = pickedItem
        }
        
        let changePin = SettingsCellItem(
            title: "Change pin",
            action: { [weak self] in
                self?.presentChangePasswordScreen?()
        })
        
        let nodeSettings = SettingsCellItem(
            title: "Daemon settings",
            action: { [weak self] in
                self?.presentNodeSettingsScreen?()
        })
        
        let currencyPicker = SettingsPickerCellItem<Currency>(
            title: "Currency",
            pickerOptions: Currency.all,
            selectedAtIndex: Currency.all.index(of: accountSettings.currency) ?? Configurations.defaultCurreny.rawValue,
            onFinish:  { [weak self] pickedItem in
                self?.accountSettings.currency = pickedItem
        })
        
        sections[.personal] = [
            changePin,
            biometricAuthSwitcher,
            rememberPasswordSwitcher
        ]
        
        let wallets = SettingsCellItem(
            title: "Add or switch wallets",
            action: { [weak self] in
                self?.presentWalletsScreen?()
        })
        
        let showKeys = SettingsCellItem(
            title: "Show keys",
            action: { [weak self] in
                self?.presentWalletKeys?()
        })
        
        sections[.wallets] = [wallets, showKeys]
        
        if showSeedIsAllow {
            let showSeed = SettingsCellItem(
                title: "Show seed",
                action: { [weak self] in
                    self?.presentWalletSeed?()
            })
            
            sections[.wallets]?.append(showSeed)
        }
        
        sections[.wallets]?.append(currencyPicker)
        sections[.wallets]?.append(feePriorityPicker)
        
        let supportUs = SettingsCellItem(
            title: "Please donate to support us!",
            action:  { [weak self] in
                self?.presentDonation?()
        })
        
        sections[.donation] = [supportUs]
        sections[.advanced] = [nodeSettings]
        
        let email = "info@caketech.io"
        let telegram = "https://t.me/cake_wallet"
        let twitter = "cakewalletXMR"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.lineSpacing = 5
        let attributes = [
            NSAttributedStringKey.font : UIFont.avenirNextMedium(size: 15),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let attributedString = NSMutableAttributedString(string: "Email: \(email)\nTelegram: \(telegram)\nTwitter: @\(twitter)", attributes: attributes)
        let telegramAddressRange = attributedString.mutableString.range(of: telegram)
        attributedString.addAttribute(.link, value: telegram, range: telegramAddressRange)
        let twitterAddressRange = attributedString.mutableString.range(of: "@\(twitter)")
        attributedString.addAttribute(.link, value: "https://twitter.com/\(twitter)", range: twitterAddressRange)
        let emailAddressRange = attributedString.mutableString.range(of: email)
        attributedString.addAttribute(.link, value: "mailto:\(email)", range: emailAddressRange)
        
        sections[.contactUs] = [SettingsTextViewCellItem(attributedString: attributedString)]
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
        cell.textLabel?.font = UIFont.avenirNextMedium(size: 15)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            section != .contactUs else {
            return 100
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = SettingsSections(rawValue: section) else {
            return 0
        }
        
        if section != .donation {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSections(rawValue: section) else {
            return nil
        }
        
        let view = UIView(frame:
            CGRect(
                origin: .zero,
                size: CGSize(width: tableView.frame.width, height: 50)))
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: view.frame.width - 20, height: view.frame.height)))
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        view.backgroundColor =  contentView.backgroundColor
        view.addSubview(titleLabel)
        
        switch section {
        case .personal:
            titleLabel.text = "Personal"
        case .wallets:
            titleLabel.text = "Wallets"
        case .advanced:
            titleLabel.text = "Advanced"
        case .contactUs:
            titleLabel.text = "Contact us"
        default:
            return nil
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
