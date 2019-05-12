import CakeWalletLib
import CakeWalletCore
import CWMonero

extension Accounts {
    public func all() -> [Account] {
        return getAll().compactMap { $0 as? Account }
    }
}

public struct UpdateAccountsHandler: Handler {
    public func handle(action: AccountsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard
            case .update = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return nil }
        return UpdateAccountsHistroyHandler()
            .handle(
                action: AccountsActions.updateFromAccounts(moneroWallet.accounts()),
                store: store
        )
    }
}

public struct UpdateAccountsHistroyHandler: Handler {
    public func handle(action: AccountsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .updateFromAccounts(accounts) = action else { return nil }
        return AccountsState.Action.changed(accounts.all())
    }
}

public struct AddNewAccountHandler: AsyncHandler {
    public func handle(action: AccountsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard
            case let .addNew(label, completionHandler) = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return handler(nil) }
        guard !label.isEmpty else { return handler(nil) }
        
        let accounts = moneroWallet.accounts()
        accounts.newAccount(withLabel: label)
        handler(AccountsState.Action.added(accounts.all()))
        completionHandler()
    }
}

public struct UpdateAccountHandler: AsyncHandler {
    public func handle(action: AccountsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard
            case let .updateAccount(label, index) = action,
            let moneroWallet = currentWallet as? MoneroWallet else { return handler(nil) }
        guard !label.isEmpty else { return handler(nil) }
        let accounts = moneroWallet.accounts()
        accounts.setLabel(label, at: index)
        let accountsList = accounts.all()
        
        
        if store.state.walletState.account.index == index,
            let account = accountsList.filter({ $0.index == index }).first {
            store.dispatch(WalletState.Action.changeAccount(account))
        }
        
        DispatchQueue.main.async {
            handler(
                AccountsState.Action.added(accountsList)
            )
        }
    }
}
