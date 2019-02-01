import Foundation
import CakeWalletLib
import CWMonero

final class Configurations {
    enum DefaultsKeys: Stringify {
        case nodeUri, nodeLogin, nodePassword, termsOfUseAccepted, currentWalletName,
        currentWalletType, biometricAuthenticationOn, passwordIsRemembered, transactionPriority,
        currency, defaultNodeChanged, autoSwitchNode, pinLength, currentTheme, termsOfUseXMRto, termsOfUseMorph, walletsDirectoryPathMigrated, masterPassword, lastBackupDate, isAutoBackupEnabled
        
        func string() -> String {
            switch self {
            case .nodeUri:
                return "node_uri"
            case .termsOfUseAccepted:
                return "terms_of_use_accepted_new" //terms_of_use_accepted
            case .nodeLogin:
                return "node_login"
            case .nodePassword:
                return "node_password"
            case .currentWalletName:
                return "current_wallet_name"
            case .currentWalletType:
                return "current_wallet_type"
            case .biometricAuthenticationOn:
                return "biometric_authentication_on"
            case .passwordIsRemembered:
                return "pin_password_is_remembered"
            case .transactionPriority:
                return "saved_fee_priority"
            case .currency:
                return "currency"
            case .defaultNodeChanged:
                return "default_node_was_changed"
            case .autoSwitchNode:
                return "auto_switch_node"
            case .pinLength:
                return "pin-length"
            case .currentTheme:
                return "current-theme"
            case .termsOfUseXMRto:
                return "terms_of_use_xmrto_accepted"
            case .termsOfUseMorph:
                return "terms_of_use_morph_accepted"
            case .walletsDirectoryPathMigrated:
                return "wallets_directory_path_migrated"
            case .masterPassword:
                return "master_password"
            case .lastBackupDate:
                return "last_backup_date"
            case .isAutoBackupEnabled:
                return "is_auto_backup_enabled"
            }
        }
    }
    
    static let defaultMoneroNode = MoneroNodeDescription(uri: "node.cakewallet.io:18081", login: "cake", password: "public_node")
    static let preDefaultNodeUri = "node.xmrbackb.one:18081"
//    static let defaultNodeUri = "opennode.xmr-tw.org:18089"
//    static let defaultCurreny = Currency.usd
    static var termsOfUseUrl: URL? {
        return Bundle.main.url(forResource: "Terms_of_Use", withExtension: "rtf")
    }
    
    static let donactionAddress = "43gN49UjHNdXDgkcWHTxceHNjXBxcKsReSNThGwzHVavHeZ4SSxSCPT8EpD5cbwAWqEqFQw12rsyTJbKGbeXo43SVpPXZ2W"
}
