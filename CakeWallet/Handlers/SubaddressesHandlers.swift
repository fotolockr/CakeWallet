import CakeWalletLib
import CakeWalletCore
import CWMonero

extension Subaddresses {
    public func all() -> [Subaddress] {
        return getAll().compactMap { $0 as? Subaddress }
    }
}

public struct UpdateSubaddressesHandler: Handler {
    public func handle(action: SubaddressesActions, store: Store<ApplicationState>) -> AnyAction? {
        guard
            case .update = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return nil }
        return UpdateSubaddressesHistroyHandler()
            .handle(
                action: SubaddressesActions.updateFromSubaddresses(moneroWallet.subaddresses()),
                store: store
        )
    }
}

public struct UpdateSubaddressesHistroyHandler: Handler {
    public func handle(action: SubaddressesActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .updateFromSubaddresses(subaddresses) = action else { return nil }
        subaddresses.refresh()
        return SubaddressesState.Action.changed(subaddresses.all())
    }
}

public struct AddNewSubaddressesHandler: AsyncHandler {
    public func handle(action: SubaddressesActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard
            case let .addNew(label, completionHandler) = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return handler(nil) }
        guard !label.isEmpty else { return handler(nil) }
        
//        DispatchQueue.main.async {
            let subaddresses = moneroWallet.subaddresses()
            subaddresses.newSubaddress(withLabel: label)
            subaddresses.refresh()
            handler(
                SubaddressesState.Action.added(subaddresses.all())
            )
            completionHandler()
//        }
    }
}

public struct UpdateSubaddressHandler: AsyncHandler {
    public func handle(action: SubaddressesActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard
            case let .updateSubaddress(label, index) = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return handler(nil) }
        guard !label.isEmpty else { return handler(nil) }
        let subaddresses = moneroWallet.subaddresses()
        subaddresses.setLabel(label, at: index)
        subaddresses.refresh()
        let subaddressesList = subaddresses.all()
        
        
        if store.state.walletState.subaddress?.index == index,
            let subaddress = subaddressesList.filter({ $0.index == index }).first {
            store.dispatch(WalletState.Action.changedSubaddress(subaddress))
        }
        
        DispatchQueue.main.async {
            handler(
                SubaddressesState.Action.added(subaddressesList)
            )
        }
    }
}
