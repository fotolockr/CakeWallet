import CakeWalletLib
import CakeWalletCore

public struct ApplicationState: StateType {
    public static func == (lhs: ApplicationState, rhs: ApplicationState) -> Bool {
        return lhs.walletState == rhs.walletState
            && lhs.walletsState == rhs.walletsState
            && lhs.settingsState == rhs.settingsState
            && lhs.balanceState == rhs.balanceState
            && lhs.blockchainState == rhs.blockchainState
            && lhs.transactionsState == rhs.transactionsState
            && lhs.subaddressesState == rhs.subaddressesState
        //            && lhs.error == rhs.error // fixme
    }
    
    public enum Action: AnyAction {
        case changedError(Error?)
    }
    
    public let walletState: WalletState
    public let walletsState: WalletsState
    public let settingsState: SettingsState
    public let balanceState: BalanceState
    public let blockchainState: BlockchainState
    public let transactionsState: TransactionsState
    public let subaddressesState: SubaddressesState
    public let accountsState: AccountsState
    public let exchangeState: ExchangeState
    public let error: Error?
    
    public init(walletState: WalletState, walletsState: WalletsState, settingsState: SettingsState, balanceState: BalanceState, blockchainState: BlockchainState, transactionsState: TransactionsState, subaddressesState: SubaddressesState, exchangeState: ExchangeState, accountsState: AccountsState, error: Error? = nil) {
        self.walletState = walletState
        self.walletsState = walletsState
        self.settingsState = settingsState
        self.balanceState = balanceState
        self.blockchainState = blockchainState
        self.transactionsState = transactionsState
        self.subaddressesState = subaddressesState
        self.exchangeState = exchangeState
        self.accountsState = accountsState
        self.error = error
    }
    
    public func reduceAny(_ action: AnyAction) -> ApplicationState? {
        if let action = action as? Action {
            return reduce(action)
        }
                
        return ApplicationState(
            walletState: walletState.reduceAny(action) ?? walletState,
            walletsState: walletsState.reduceAny(action) ?? walletsState,
            settingsState: settingsState.reduceAny(action) ?? settingsState,
            balanceState: balanceState.reduceAny(action) ?? balanceState,
            blockchainState: blockchainState.reduceAny(action) ?? blockchainState,
            transactionsState: transactionsState.reduceAny(action) ?? transactionsState,
            subaddressesState: subaddressesState.reduceAny(action) ?? subaddressesState,
            exchangeState: exchangeState.reduceAny(action) ?? exchangeState,
            accountsState: accountsState.reduceAny(action) ?? accountsState,
            error: error
        )
    }
    
    public func reduce(_ action: ApplicationState.Action) -> ApplicationState {
        switch action {
        case let .changedError(error):
            return ApplicationState(
                walletState: walletState,
                walletsState: walletsState,
                settingsState: settingsState,
                balanceState: balanceState,
                blockchainState: blockchainState,
                transactionsState: transactionsState,
                subaddressesState: subaddressesState,
                exchangeState: exchangeState,
                accountsState: accountsState,
                error: error
            )
        }
    }
    
    
}
