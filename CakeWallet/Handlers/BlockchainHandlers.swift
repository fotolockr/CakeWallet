import CakeWalletLib
import CakeWalletCore

public struct FetchBlockchainHeightHandler: AsyncHandler {
    public func handle(action: BlockchainActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .fetchBlockchainHeight = action else { return }
        
        workQueue.async {
            do {
                let height = try currentWallet.blockchainHeight()
                handler(BlockchainState.Action.changedBlockchainHeight(height))
            } catch {
                handler(ApplicationState.Action.changedError(error))
            }
        }
    }
}

public struct CheckConnectionHandler: AsyncHandler {
    public func handle(action: BlockchainActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .checkConnection = action else { return }
        
        backgroundConnectionTimerQueue.async {
            guard
                let node = store.state.settingsState.node,
                !currentWallet.isConnected else { return }
            node.isAble() { isAble in
                if isAble {
                    store.dispatch(
                        WalletActions.connect(node)
                    )
                } else if store.state.settingsState.isAutoSwitchNodeOn {
                    print("Need switch node!")
                    switchNode()
                }
            }
        }
    }
}
