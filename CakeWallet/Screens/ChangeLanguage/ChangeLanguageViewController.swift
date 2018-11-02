import UIKit
import CakeWalletLib

// fixme

public enum Languages: String, Formatted {
    case en = "Base"
    case cn = "zh-Hans"
    case pt = "pt-PT"
    case pl = "pl"
    case ru, es, ja, ko, hi, de, nl
    
    public static var current: Languages? {
        var lang = NSLocale.preferredLanguages.first!
        
        if lang == "base" {
            lang = lang.capitalized
        }
        
        return Languages(from: lang)
    }
    
    public init?(from string: String) {
        if string.lowercased() == "en" {
            self = .en
            return
        }
        
        if let lang = Languages(rawValue: string) {
           self = lang
        } else {
            let value = string.components(separatedBy: "-").first!
            self.init(rawValue: value)
        }
    }
    
    public func formatted() -> String {
        switch self {
        case .en:
            return "English"
        case .ru:
            return "Русский (Russian)"
        case .es:
            return "Español (Spanish)"
        case .ja:
            return "日本 (Japanese)"
        case .ko:
            return "한국어 (Korean)"
        case .de:
            return "Deutsch (German)"
        case .hi:
            return "हिंदी (Hindi)"
        case .cn:
            return "中文 (Chinese)"
        case .pt:
            return "Português (Portuguese)"
        case .pl:
            return "Polskie (Polish)"
        case .nl:
            return "Nederlands (Dutch)"
        }
    }
}

extension Languages: CellItem {
    func setup(cell: LangTableCcell) {
        cell.configure(lang: self, isCurrent: self == Languages.current)
    }
}

extension String {
    
    public func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
}

extension Bundle {

    static func localizedBundle(for lang: Languages) -> Bundle {
        guard let path = Bundle.main.path(forResource: lang.rawValue, ofType: "lproj") else {
            return Bundle.main
        }
        
        return Bundle(path: path)!
    }
    
}

private var kBundleKey: UInt8 = 0

class BundleEx: Bundle {
    static let shared = BundleEx()
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) {
            return (bundle as! Bundle).localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
    
}

extension Bundle {
    
    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
    }()
    
    class func setLanguage(_ language: String?) {
        Bundle.once
        let isLanguageRTL = Bundle.isLanguageRTL(language)
        UIView.appearance().semanticContentAttribute = isLanguageRTL ? .forceRightToLeft : .forceLeftToRight
        
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.set(isLanguageRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(isLanguageRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.synchronize()
        
        let value = (language != nil ? Bundle.init(path: (Bundle.main.path(forResource: language, ofType: "lproj"))!) : nil)
        objc_setAssociatedObject(Bundle.main, &kBundleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NotificationCenter.default.post(name: Notification.Name("langChanged"), object: true)
    }
    
    class func isLanguageRTL(_ languageCode: String?) -> Bool {
        return (languageCode != nil && Locale.characterDirection(forLanguage: languageCode!) == .rightToLeft)
    }
    
}

final class ChangeLanguageViewController: BaseViewController<ChangeLanguageView>, UITableViewDelegate, UITableViewDataSource {
    let languages: [Languages] = [.en, .ru, .es, .ja, .ko, .hi, .de, .cn, .pt, .pl, .nl]
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("change_language", comment: "")
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [Languages.self])
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = languages[indexPath.row]
        return tableView.dequeueReusableCell(withItem: language, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        let changeAction = CWAlertAction(title: NSLocalizedString("change", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.changeLanguage(to: language)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        showInfo(
            title: NSLocalizedString("change_language", comment: ""),
            message: String(format: NSLocalizedString("change_language_ask", comment: ""), language.formatted()),
            actions: [changeAction, CWAlertAction.cancelAction]
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    private func changeLanguage(to language: Languages) {
        Bundle.setLanguage(language.rawValue)
        navigationController?.popViewController(animated: true)
    }
}
