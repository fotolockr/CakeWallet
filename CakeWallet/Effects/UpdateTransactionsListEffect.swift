import CakeWalletLib
import CakeWalletCore

public final class UpdateTransactionsListEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BalanceState.Action) -> AnyAction? {
        guard
            case .changedBalance(_) = action else {
                return action
        }
        
        var amount = store.state.balanceState.balance
        
        switch action {
        case let .changedBalance(_amount):
            amount = _amount
        case let .changedUnlockedBalance(_amount):
            amount = _amount
        default:
            break
        }
        
        if amount.compare(with: store.state.balanceState.balance) {
            store.dispatch(
                TransactionsActions.updateTransactionHistory(currentWallet.transactions())
            )
        }
        
        return action
    }
}
