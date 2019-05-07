import CakeWalletCore
import CakeWalletLib
import CWMonero

public struct AccountsState: StateType {
    public static func == (lhs: AccountsState, rhs: AccountsState) -> Bool {
        return lhs.accounts == rhs.accounts
        
    }
    
    public enum Action: AnyAction {
        case changed([Account])
        case added([Account])
    }
    
    public let accounts: [Account]
    
    public init(accounts: [Account]) {
        self.accounts = accounts
    }
    
    public func reduce(_ action: AccountsState.Action) -> AccountsState {
        switch action {
        case let .changed(accounts):
            return AccountsState(accounts: accounts)
        case let .added(accounts):
            return AccountsState(accounts: accounts)
        }
    }
}
