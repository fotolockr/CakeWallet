import CakeWalletCore

final class OnCurrentNodeChangeEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: SettingsState.Action) -> AnyAction? {
        workQueue.async {
            switch action {
            case let .changeCurrentNode(node):
                store.dispatch(
                    WalletActions.connect(node)
                )
            default:
                break
            }
        }
        
        return action
    }
}
