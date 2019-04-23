import Foundation
import CakeWalletLib
import CakeWalletCore
import CWMonero

// fixme
private let moneroBlockSize = 1000

private func onWalletChange(_ wallet: Wallet) {
    if wallet.name != UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentWalletName) {
        UserDefaults.standard.set(wallet.name, forKey: Configurations.DefaultsKeys.currentWalletName)
    }
    
    if currentWallet != nil && (currentWallet.name != wallet.name) {
        currentWallet.close()
    }
    
    currentWallet = wallet
    
    currentWallet.onAddressChange = { address in
        store.dispatch(WalletState.Action.changedAddress(address))
    }
    
    currentWallet.onNewBlock = { block in
        updateQueue.async {
            store.dispatch(
                BlockchainState.Action.changedConnectionStatus(.syncing(block))
            )
        }
    }
   
    currentWallet.onConnectionStatusChange = { conntectionStatus in
        store.dispatch(
            BlockchainState.Action.changedConnectionStatus(conntectionStatus)
        )
    }
    
    currentWallet.onBalanceChange = { wallet in
        store.dispatch(
            BalanceState.Action.changedBalance(wallet.balance)
        )
        
        store.dispatch(
            BalanceState.Action.changedUnlockedBalance(wallet.unlockedBalance)
        )
        
        store.dispatch(
            BalanceActions.updateFiatPrice
        )
    }
    
    if let moneroWallet = currentWallet as? MoneroWallet {
        moneroWallet.onAccountIndexChange = { index in
            store.dispatch(WalletState.Action.changedAccountIndex(index))
            store.dispatch(TransactionsActions.updateTransactionHistory(currentWallet.transactions()))
        }
    }
    
    store.dispatch(
        TransactionsActions.updateTransactionHistory(currentWallet.transactions())
    )
    
    store.dispatch(
        BlockchainState.Action.changedCurrentHeight(wallet.currentHeight)
    )
    
    store.dispatch(
        BalanceState.Action.changedBalance(wallet.balance)
    )
    
    store.dispatch(
        BalanceState.Action.changedUnlockedBalance(wallet.unlockedBalance)
    )
}

public final class OnWalletChangeEffect: Effect {
    public func effect(_ store: Store<ApplicationState>, action: WalletState.Action) -> AnyAction? {
        switch action {
        case let .loaded(wallet):
            onWalletChange(wallet)
        case let .created(wallet):
            onWalletChange(wallet)
        case let .restored(wallet):
            onWalletChange(wallet)
        case let .inited(wallet):
            onWalletChange(wallet)
        default:
            break
        }
        
        return action
    }
}

