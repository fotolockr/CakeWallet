import Foundation

public protocol Effect: AnyEffect {
    associatedtype State: StateType
    associatedtype Action: AnyAction
    func effect(_ store: Store<State>, action: Action) -> AnyAction?
}

extension Effect {
    public func anyEffect(_ store: AnyStore, action: AnyAction) -> AnyAction? {
        guard let store = store as? Store<State>, let _action = action as? Action else {
            return action
        }
        
        return effect(store, action: _action)
    }
}

public final class HandlerEffect<State: StateType>: AnyEffect {
    public init() {}
    
    public func anyEffect(_ store: AnyStore, action: AnyAction) -> AnyAction? {
        guard let store = store as? Store<State> else {
            return action
        }
        
        return effect(store, action: action)
    }
    
    public func effect(_ store: Store<State>, action: AnyAction) -> AnyAction? {
        guard let _action = action as? HandlableAction else {
            return action
        }
        
        for handler in handlers {
            if let handler = handler as? AnyAsyncHandler  {
                handler.handle(anyAction: _action, store: store) { _action in
                    if let action = _action {
                        store.dispatch(action)
                    }
                }
                
                continue
            }
            
            if let action = handler.handle(anyAction: _action, store: store) {
                store.dispatch(action)
            }
        }

        return action
    }
}
