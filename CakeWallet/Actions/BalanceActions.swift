import CakeWalletLib
import CakeWalletCore

public enum BalanceActions: HandlableAction {
    case updateFiatPrice(currency: FiatCurrency)
    case updateFiatBalance(price: Double)
}
