import CakeWalletLib
import CakeWalletCore
import CWMonero

public enum AccountsActions: HandlableAction {
    case update
    case updateFromAccounts(Accounts)
    case addNew(withLabel: String, handler: () -> Void)
    case updateAccount(String, UInt32)
}
