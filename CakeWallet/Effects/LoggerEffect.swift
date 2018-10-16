import CakeWalletCore

public final class LoggerEffect<State: StateType>: AnyEffect {
    public init() {}
    
    public func anyEffect(_ store: AnyStore, action: AnyAction) -> AnyAction? {
        guard let store = store as? Store<State> else {
            return action
        }
        
        return effect(store, action: action)
    }
    
    public func effect(_ store: Store<State>, action: AnyAction) -> AnyAction? {
        print("action: \(action)\n")
        return action
    }
}
