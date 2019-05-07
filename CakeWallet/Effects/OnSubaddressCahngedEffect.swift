import CWMonero
import CakeWalletLib
import CakeWalletCore

public final class OnSubaddressCahngedEffect: Effect {
    public func effect(_ store: Store<ApplicationState>, action: WalletState.Action) -> AnyAction? {
        guard case let .changedSubaddress(subaddress) = action else {
            return action
        }
        
        if let moneroWallet = currentWallet as? MoneroWallet {
            let index = subaddress?.index ?? 0
            moneroWallet.changeAddress(index: index)
        }
        
        return action
    }
}

