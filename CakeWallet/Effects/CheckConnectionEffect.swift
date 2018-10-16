import CakeWalletCore

final class CheckConnectionEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BlockchainState.Action) -> AnyAction? {
//        switch action {
//        case let .changedConnectionStatus(status):
//            if .failed == status {
//                store.dispatch(
//                    BlockchainActions.checkConnection
//                )
//            }
//        default:
//            break
//        }
        
        return action
    }
}
