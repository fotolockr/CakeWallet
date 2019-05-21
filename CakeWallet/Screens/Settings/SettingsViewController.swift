import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout
import ZIPFoundation
import CryptoSwift
import CWMonero
import SwiftyJSON


final class TextViewUITableViewCell: FlexCell {
    let textView: UITextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = UITextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        contentView.addSubview(textView)
        accessoryType = .none
    }
    
    override func configureConstraints() {
        contentView.flex.addItem(textView).marginLeft(15).width(100%).height(100%)
    }
    
    func configure(attributedText: NSAttributedString) {
        textView.attributedText = attributedText
        textView.flex.markDirty()
        contentView.flex.layout(mode: .adjustHeight)
    }
}

final class SettingsViewController: BaseViewController<SettingsView>, UITableViewDelegate, UITableViewDataSource {
    enum SettingsSections: Int {
        case wallets, personal, backup, manualBackup, advanced, support
    }
    
    struct SettingsTextViewCellItem: CellItem {
        let attributedString: NSAttributedString
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
        
        func setup(cell: TextViewUITableViewCell) {
            cell.configure(attributedText: attributedString)
        }
    }
    
    struct SettingsCellItem: CellItem {
        let title: String
        let action: (() -> Void)?
        let image: UIImage?
        
        init(title: String, image: UIImage? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryView = UIImageView(image: UIImage(named: "arrow_right")?.resized(to: CGSize(width: 6, height: 10)))
        }
    }
    
    final class SettingsSwitchCellItem: CellItem {
        let title: String
        let image: UIImage?
        let action: ((Bool, SettingsSwitchCellItem) -> Void)?
        let switcher: SwitchView = SwitchView()
        
        init(title: String, image: UIImage? = nil, isOn: Bool, action: ((Bool, SettingsSwitchCellItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.switcher.isOn = isOn
            config()
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryView = switcher
            switcher.onChangeHandler = { isOn in
                self.action?(isOn, self)
            }
        }
        
        private func config() {
            switcher.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 35))
        }
    }
    
    struct SettingsPickerCellItem<PickerItem: Formatted>: CellItem {
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
    
    weak var settingsFlow: SettingsFlow?
    
    var transactionPriority: TransactionPriority {
        return store.state.settingsState.transactionPriority
    }
    
    var fiatCurrency: FiatCurrency {
        return store.state.settingsState.fiatCurrency
    }
    
    private let store: Store<ApplicationState>
    private var sections: [SettingsSections: [CellAnyItem]]
    private let backupService: BackupServiceImpl
    private var masterPassword: String {
        return try! KeychainStorageImpl.standart.fetch(forKey: .masterPassword)
    }
    
    init(store: Store<ApplicationState>, settingsFlow: SettingsFlow?, backupService: BackupServiceImpl) {
        self.store = store
        self.settingsFlow = settingsFlow
        self.backupService = backupService
        sections = [.wallets: [], .personal: [], .advanced: []]
        super.init()
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "settings_icon")?.resized(to: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "settings_selected_icon")?.resized(to: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func configureBinds() {
        contentView.table.register(items: [
            SettingsTextViewCellItem.self,
            SettingsCellItem.self,
            SettingsPickerCellItem<TransactionPriority>.self,
            SettingsPickerCellItem<FiatCurrency>.self
            ])
        contentView.table.delegate = self
        contentView.table.dataSource = self
        let transactionPriorities = [
            TransactionPriority.slow,
            TransactionPriority.default,
            TransactionPriority.fast,
            TransactionPriority.fastest
        ]
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        let fiatCurrencyCellItem = SettingsPickerCellItem<FiatCurrency>(
            title: NSLocalizedString("currency", comment: ""),
            pickerOptions: FiatCurrency.all,
            selectedAtIndex: FiatCurrency.all.index(of: fiatCurrency) ?? 0) { [weak store] currency in
                store?.dispatch(
                    SettingsActions.changeCurrentFiat(currency: currency)
                )
        }
        
        let feePriorityCellItem = SettingsPickerCellItem<TransactionPriority>(
            title: NSLocalizedString("fee_priority", comment: ""),
            pickerOptions: transactionPriorities,
            selectedAtIndex: transactionPriorities.index(of: transactionPriority) ?? 0) { [weak store] priority in
                store?.dispatch(
                    SettingsActions.changeTransactionPriority(priority)
                )
        }
        
        let changePinCellItem = SettingsCellItem(title: NSLocalizedString("change_pin", comment: ""), action: { [weak self] in
            self?.presentChangePin()
        })
        
        let changeLanguage = SettingsCellItem(title: NSLocalizedString("change_language", comment: ""), action: { [weak self] in //fixme
            self?.presentChangeLanguage()
        })
        
        let biometricCellItem = SettingsSwitchCellItem(
            title: NSLocalizedString("allow_biometric_authentication", comment: ""),
            isOn: store.state.settingsState.isBiometricAuthenticationAllowed,
            action: { [weak store] isAllowed, item in
                guard isAllowed != store?.state.settingsState.isBiometricAuthenticationAllowed else {
                    return
                }
                
                store?.dispatch(
                    SettingsActions.changeBiometricAuthentication(isAllowed: isAllowed, handler: { isAllowed in
                        DispatchQueue.main.async {
                            item.switcher.isOn = isAllowed
                        }
                    })
                )
        })
//        let rememberPasswordCellItem = SettingsSwitchCellItem(
//            title: NSLocalizedString("remember_pin", comment: ""),
//            isOn: false // accountSettings.isPasswordRemembered
//        ) { [weak self] isOn, item in
//            //                self?.accountSettings.isPasswordRemembered = isOn
//        }
        let daemonSettingsCellItem = SettingsCellItem(
            title: NSLocalizedString("node_settings", comment: ""),
            action: { [weak self] in
                self?.settingsFlow?.change(route: .nodes)
        })
        let termSettingsCellItem = SettingsCellItem(
            title: NSLocalizedString("terms", comment: ""),
            action: { [weak self] in
                self?.settingsFlow?.change(route: .terms)
        })
        let createBackupCellItem = SettingsCellItem(
            title: NSLocalizedString("save_backup_file", comment: ""),
            action: { [weak self] in
                self?.askToShowBackupPasswordAlert() {
                    self?.showSpinnerAlert(withTitle: NSLocalizedString("creating_backup", comment: "")) { [weak self] alert in
                        do {
                            guard
                                let password = self?.masterPassword,
                                let backupService = self?.backupService else {
                                    return
                            }
                            
                            let url = try backupService.exportToTmpFile(withPassword: password)
                            
                            alert.dismiss(animated: true) {
                                let activityViewController = UIActivityViewController(
                                    activityItems: [url],
                                    applicationActivities: nil)
                                activityViewController.excludedActivityTypes = [
                                    UIActivityType.message, UIActivityType.mail,
                                    UIActivityType.print, UIActivityType.airDrop]
                                self?.present(activityViewController, animated: true)
                            }
                        } catch {
                            alert.dismiss(animated: true) {
                                self?.onBackupSave(error: error)
                            }
                        }
                    }
                }
        })
        let backupNowCellItem = SettingsCellItem(
            title: NSLocalizedString("backup_now", comment: ""),
            action: { [weak self] in
                self?.askToShowBackupPasswordAlert() {
                    self?.showSpinnerAlert(withTitle: NSLocalizedString("creating_backup", comment: "")) { [weak self] alert in
                        autoBackup(force: true, handler: { error in
                            alert.dismiss(animated: true) {
                                guard let error = error else {
                                    self?.showOKInfoAlert(
                                        title: NSLocalizedString("backup_uploaded", comment: ""),
                                        message: NSLocalizedString("backup_uploaded_icloud", comment: "")
                                    )
                                    return
                                }
                                
                                self?.onBackupSave(error: error)
                            }
                        })
                    }
                }
        })
        let showMasterPasswordCellItem = SettingsCellItem(
            title: NSLocalizedString("show_backup_password", comment: ""),
            action: { [weak self] in
                self?.showBackupPassword()
        })
        let autoBackupSwitcher = SettingsSwitchCellItem(
            title: NSLocalizedString("auto_backup", comment: ""),
            isOn: UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.isAutoBackupEnabled)
        ) { [weak self] isEnabled, item in
            if isEnabled {
                let icloud = ICloudStorage()
                guard icloud.isEnabled() else {
                    UserDefaults.standard.set(false, forKey: Configurations.DefaultsKeys.isAutoBackupEnabled)
                    item.switcher.isOn = false
                    self?.showICloudIsNotEnabledAlert()
                    return
                }
                
                self?.askToShowBackupPasswordAlert(onCancelHandler: {
                    item.switcher.isOn = false
                    UserDefaults.standard.set(false, forKey: Configurations.DefaultsKeys.isAutoBackupEnabled)
                }, onSavedHandler: {
                    UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.isAutoBackupEnabled)
                    autoBackup(cloudStorage: icloud, force: true, queue: .main) { error in
                        DispatchQueue.main.async {
                            guard let error = error else {
                                return
                            }
                            
                            item.switcher.isOn = false
                            self?.showICloudIsNotEnabledAlert()
                            self?.onBackupSave(error: error)
                        }
                    }
                })
                
                return
            }
            
            UserDefaults.standard.set(isEnabled, forKey: Configurations.DefaultsKeys.isAutoBackupEnabled)
        }
        let changeMasterPassword = SettingsCellItem(
            title: NSLocalizedString("change_backup_password", comment: ""),
            action: { [weak self] in
                let changeAction = UIAlertAction(title: NSLocalizedString("change", comment: ""), style: .default, handler: { alert in
                    let authVC = AuthenticationViewController(store: self!.store, authentication: AuthenticationImpl())
                    authVC.handler = { [weak self, weak authVC] in
                        authVC?.dismiss(animated: true) {
                            let changePassword: (String, (() -> Void)?) -> Void = { password, handler in
                                let keychainStorage = KeychainStorageImpl.standart
                                do {
                                    try keychainStorage.set(value: password, forKey: .masterPassword)
                                    handler?()
                                    autoBackup(force: true) { error in
                                        if let error = error {
                                            self?.dismissAlert({
                                                self?.showErrorAlert(error: error)
                                            })
                                        }
                                    }
                                } catch {
                                    self?.showErrorAlert(error: error)
                                }
                            }
                            let alert = UIAlertController(
                                title: NSLocalizedString("change_master_password", comment: ""),
                                message: NSLocalizedString("enter_new_password", comment: ""), preferredStyle: .alert
                            )
                            
                            alert.addTextField { textField in
                                textField.isSecureTextEntry = true
                            }
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("generate_new_password", comment: ""), style: .default, handler: { _ in
                                let password = UUID().uuidString
                                changePassword(password) {
                                    let copyAction = UIAlertAction(title: NSLocalizedString("copy", comment: ""), style: .default) { [weak self] _ in
                                        UIPasteboard.general.string = self?.masterPassword
                                    }
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                    
                                    self?.showInfoAlert(
                                        title: NSLocalizedString("backup_password", comment: ""),
                                        message: "Backup password has changed successfuly!\nYour new backup password: \(password)",
                                        actions: [okAction, copyAction]
                                    )
                                }
                            }))
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] _ in
                                guard let password = alert?.textFields?.first?.text else {
                                    return
                                }
                                
                                changePassword(password) {
                                    self?.showOKInfoAlert(
                                        title: NSLocalizedString("backup_password", comment: ""),
                                        message: NSLocalizedString("backup_password_has_changed", comment: "")
                                    )
                                }
                            }))
                            
                            self?.present(alert, animated: true)
                        }
                    }
                    
                    let authNavVC = UINavigationController(rootViewController: authVC)
                    self?.present(authNavVC, animated: true)
                })
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
                
                self?.showInfoAlert(
                    title: NSLocalizedString("backup_password", comment: ""),
                    message: NSLocalizedString("change_backup_warning", comment: ""),
                    actions: [cancelAction, changeAction])
        })
        
        sections[.wallets] = [
            fiatCurrencyCellItem,
            feePriorityCellItem
        ]
        sections[.personal] = [
            changePinCellItem,
            changeLanguage,
            biometricCellItem,
//            rememberPasswordCellItem
        ]
        sections[.advanced] = [
            daemonSettingsCellItem
        ]
        sections[.backup] = [
            showMasterPasswordCellItem,
            changeMasterPassword,
            autoBackupSwitcher,
            backupNowCellItem
        ]
        sections[.manualBackup] = [
            createBackupCellItem
        ]
        
        
        //fixme
        let email = "support@cakewallet.io"
        let telegram = "https://t.me/cake_wallet"
        let twitter = "cakewalletXMR"
        let morphEmail = "contact@morphtoken.com"
        let xmrtoEmail = "support@xmr.to"
        let changeNowEmail = "support@changenow.io"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.lineSpacing = 5
        let attributes = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let attributedString = NSMutableAttributedString(
            string: String(format: "Email: %@\nTelegram: %@\nTwitter: @%@\nExchange (ChangeNow): %@\nExchange (Morph): %@\nExchange(xmr->btc): %@", email, telegram, twitter, changeNowEmail, morphEmail, xmrtoEmail),
            attributes: attributes)
        let telegramAddressRange = attributedString.mutableString.range(of: telegram)
        attributedString.addAttribute(.link, value: telegram, range: telegramAddressRange)
        let twitterAddressRange = attributedString.mutableString.range(of: String(format: "@%@", twitter))
        attributedString.addAttribute(.link, value: String(format: "https://twitter.com/%@", twitter), range: twitterAddressRange)
        let emailAddressRange = attributedString.mutableString.range(of: email)
        attributedString.addAttribute(.link, value: String(format: "mailto:%@", email), range: emailAddressRange)
        let morphAddressRange = attributedString.mutableString.range(of: morphEmail)
        attributedString.addAttribute(.link, value: String(format: "mailto:%@", morphEmail), range: morphAddressRange)
        
        let changenowAddressRange = attributedString.mutableString.range(of: changeNowEmail)
        attributedString.addAttribute(.link, value: String(format: "mailto:%@", changeNowEmail), range: changenowAddressRange)
        
        let xmrAddressRange = attributedString.mutableString.range(of: xmrtoEmail)
        attributedString.addAttribute(.link, value: String(format: "mailto:%@", morphEmail), range: xmrAddressRange)
        let contactUsCellItem = SettingsTextViewCellItem(attributedString: attributedString)
        
        sections[.support] = [
            contactUsCellItem,
            termSettingsCellItem
        ]
        
        if
            let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            contentView.footerLabel.text = String(format: "%@ %@", NSLocalizedString("version", comment: ""), version)
        }
    }
    
    override func setTitle() {
        title = NSLocalizedString("settings", comment: "")
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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            !(section == .support && indexPath.row == 0) else { //fixme: hardcoded value!!
                return 175
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSections(rawValue: section) else {
            return nil
        }
        
        let view = UIView(frame:
            CGRect(
                origin: .zero,
                size: CGSize(width: tableView.frame.width, height: 60)))
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 5), size: CGSize(width: view.frame.width - 20, height: view.frame.height)))
        titleLabel.font = applyFont(ofSize: 16)
        titleLabel.textColor = Theme.current.lightText
        view.backgroundColor =  contentView.backgroundColor
        view.addSubview(titleLabel)
        
        switch section {
        case .personal:
            titleLabel.text = NSLocalizedString("personal", comment: "")
        case .wallets:
            titleLabel.text = NSLocalizedString("wallets", comment: "")
        case .advanced:
            titleLabel.text = NSLocalizedString("advanced", comment: "")
        case .support:
            titleLabel.text = NSLocalizedString("support", comment: "")
        case .backup:
            titleLabel.text = NSLocalizedString("backup", comment: "")
        case .manualBackup:
            titleLabel.text = NSLocalizedString("manual_backup", comment: "")
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
    
    private func presentChangePin() {
        let authViewController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        authViewController.handler = { [weak self, weak authViewController] in
            authViewController?.dismiss(animated: false, completion: {
                self?.settingsFlow?.change(route: .changePin)
            })
        }
        
        present(UINavigationController(rootViewController: authViewController), animated: true)
    }
    
    private func askToShowBackupPasswordAlert(onCancelHandler: (() -> Void)? = nil, onSavedHandler: @escaping () -> Void) {
        let savedAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { _ in
            onSavedHandler()
        }
        let showBackupPassowrd = UIAlertAction(title: NSLocalizedString("show_password", comment: ""), style: .default) { [weak self] _ in
            self?.showBackupPassword()
            onCancelHandler?()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        showInfoAlert(
            title: NSLocalizedString("backup", comment: ""),
            message: NSLocalizedString("save_backup_password", comment: ""),
            actions: [savedAction, showBackupPassowrd, cancelAction]
        )
    }
    
    private func showBackupPassword() {
        let copyAction = UIAlertAction(title: NSLocalizedString("copy", comment: ""), style: .default) { [weak self] _ in
            UIPasteboard.general.string = self?.masterPassword
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        let authVC = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        authVC.handler = { [weak self] in
            authVC.dismiss(animated: true) {
                self?.showInfoAlert(
                    title: NSLocalizedString("backup_password", comment: ""),
                    message: self!.masterPassword, actions: [copyAction, cancelAction]
                )
            }
        }
        
        let authNavVC = UINavigationController(rootViewController: authVC)
        present(authNavVC, animated: true)
    }
    
    private func presentChangeLanguage() {
        settingsFlow?.change(route: .changeLanguage)
    }
    
    private func toggleNightMode(isOn: Bool) {
        NotificationCenter.default.post(name: Notification.Name("changeTheme"), object: isOn ? Theme.night : Theme.def)
    }
    
    private func showICloudIsNotEnabledAlert() {
        showOKInfoAlert(message: NSLocalizedString("enable_icloud", comment: ""))
    }
    
    private func onBackupSave(error: Error) {
        if case ICloudStorageError.notEnabled = error {
            showICloudIsNotEnabledAlert()
            return
        }
        
        showErrorAlert(error: error)
    }
}
