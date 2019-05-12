import Foundation
import CakeWalletLib
import CakeWalletCore
import CWMonero

// fixme
private let moneroBlockSize = 1000

private func onWalletChange(_ wallet: Wallet) {
    syncedHeight = 0
    
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
        store.dispatch(
            BlockchainState.Action.changedConnectionStatus(.syncing(block))
        )
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
    
    currentWallet.transactions().transactionsChanged = { transactions in
        let account: UInt32
        
        if let moneroWallet = currentWallet as? MoneroWallet {
            account = moneroWallet.accountIndex
        } else {
            account = 0
        }
        
        store.dispatch(TransactionsActions.updateTransactions(transactions, account))
        
//        do {
//            try currentWallet.save()
//        } catch {
//            store.dispatch(ApplicationState.Action.changedError(error))
//        }
    }
    
    store.dispatch(
        BlockchainState.Action.changedCurrentHeight(wallet.currentHeight)
    )
    
    store.dispatch(
        BalanceState.Action.changedBalance(wallet.balance)
    )
    
    store.dispatch(
        BalanceState.Action.changedUnlockedBalance(wallet.unlockedBalance)
    )
    
    guard let moneroWallet = currentWallet as? MoneroWallet else {
        return
    }
    
    let accounts = moneroWallet.accounts()

    if let account = accounts.all().filter({ $0.index == 0 }).first {
        store.dispatch(WalletState.Action.changeAccount(account))
    }
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

