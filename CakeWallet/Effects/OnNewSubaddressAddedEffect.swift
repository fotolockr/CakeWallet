import CakeWalletLib
import CakeWalletCore

public final class OnNewSubaddressAddedEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: SubaddressesState.Action) -> AnyAction? {
        guard case .added(_) = action else {
            return action
        }
        
        do {
            try currentWallet.save()
        } catch {
            store.dispatch(ApplicationState.Action.changedError(error))
        }
        
        return action
    }
}
