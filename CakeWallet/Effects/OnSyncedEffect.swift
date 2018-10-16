import Foundation
import UIKit
import CakeWalletLib
import CakeWalletCore

public final class OnSyncedEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BlockchainState.Action) -> AnyAction? {
        guard
            case let .changedConnectionStatus(connectionStatus) = action,
            .synced == connectionStatus else {
                return action
        }
        
        workQueue.async {
            do {
                try currentWallet.save()
                store.dispatch(
                    TransactionsActions.updateTransactionHistory(currentWallet.transactions())
                )
            } catch {
                store.dispatch(ApplicationState.Action.changedError(error))
            }
            
            if !currentWallet.balance.compare(with: store.state.balanceState.balance) {
                store.dispatch(BalanceState.Action.changedBalance(currentWallet.balance))
            }
            
            if !currentWallet.unlockedBalance.compare(with: store.state.balanceState.unlockedBalance) {
                store.dispatch(BalanceState.Action.changedUnlockedBalance(currentWallet.unlockedBalance))
            }
        }
        
        return action
    }
}
