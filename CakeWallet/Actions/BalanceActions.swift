import CakeWalletLib
import CakeWalletCore

public enum BalanceActions: HandlableAction {
    case updateFiatPrice
    case updateFiatBalance(price: Double)
}
