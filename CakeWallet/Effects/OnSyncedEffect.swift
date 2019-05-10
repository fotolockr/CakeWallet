import Foundation
import UIKit
import CakeWalletLib
import CakeWalletCore

var syncedHeight = 0 as UInt64

public final class OnSyncedEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BlockchainState.Action) -> AnyAction? {
        guard
            case let .changedConnectionStatus(connectionStatus) = action,
            .synced == connectionStatus else {
                return action
        }
        
        workQueue.async {
            currentWallet.transactions().askToUpdate()
            
            if !currentWallet.balance.compare(with: store.state.balanceState.balance) {
                store.dispatch(BalanceState.Action.changedBalance(currentWallet.balance))
            }
            
            if !currentWallet.unlockedBalance.compare(with: store.state.balanceState.unlockedBalance) {
                store.dispatch(BalanceState.Action.changedUnlockedBalance(currentWallet.unlockedBalance))
            }
        }
        
        let currentHeight = currentWallet.currentHeight
        let diff = currentHeight - syncedHeight

        if syncedHeight == 0 || diff >= 100 {
            do {
                try currentWallet.save()
            } catch {
                store.dispatch(ApplicationState.Action.changedError(error))
            }
            
            syncedHeight = currentHeight
        }
        
        return action
    }
}
