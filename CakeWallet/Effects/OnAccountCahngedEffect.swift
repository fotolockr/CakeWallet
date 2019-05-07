import CWMonero
import CakeWalletLib
import CakeWalletCore

public final class OnAccountCahngedEffect: Effect {
    public func effect(_ store: Store<ApplicationState>, action: WalletState.Action) -> AnyAction? {
        guard case let .changeAccount(account) = action else {
            return action
        }
        
        if let moneroWallet = currentWallet as? MoneroWallet {
            let index = account.index
            moneroWallet.changeAccount(index: index)
        }
        
        store.dispatch(WalletState.Action.changedSubaddress(nil))
        store.dispatch(TransactionsActions.forceUpdateTransactions)
        return action
    }
}
