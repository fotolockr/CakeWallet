import CakeWalletLib
import CakeWalletCore

public struct FetchWalletsHandler: AsyncHandler {
    public func handle(action: WalletsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .fetchWallets = action else { return }
        
        workQueue.async {
            let wallets = gateways.reduce([WalletIndex](), { res, gateway -> [WalletIndex] in
                return res + gateway.fetchWalletsList()
            })
            
            store.dispatch(WalletsState.Action.fetchedWallets(wallets))
        }
    }
}
