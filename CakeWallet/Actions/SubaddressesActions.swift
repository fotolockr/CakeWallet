import CakeWalletLib
import CakeWalletCore
import CWMonero

public enum SubaddressesActions: HandlableAction {
    case update
    case updateFromSubaddresses(Subaddresses)
    case addNew(withLabel: String, handler: () -> Void)
    case updateSubaddress(String, UInt32)
}
