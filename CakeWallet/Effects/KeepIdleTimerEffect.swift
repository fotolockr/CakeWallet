import CakeWalletCore

public final class KeepIdleTimerEffect: Effect {
    private var isSyncing: Bool
    
    public init() {
        isSyncing = false
    }
    
    public func effect(_ store: Store<ApplicationState>, action: BlockchainState.Action) -> AnyAction? {
        // fixme
        
//        guard case let .changedConnectionStatus(connectionStatus) = action else {
//            return action
//        }
//
//        DispatchQueue.main.async {
//            switch connectionStatus {
//            case .syncing(_):
//                self.isSyncing = true
//                if !UIApplication.shared.isIdleTimerDisabled {
//                    UIApplication.shared.isIdleTimerDisabled = true
//                }
//            default:
//                self.isSyncing = false
//                if UIApplication.shared.isIdleTimerDisabled {
//                    UIApplication.shared.isIdleTimerDisabled = false
//                }
//            }
//        }
        
        return action
    }
}
