import Foundation

public final class Store<State: StateType>: StoreType {
    public private(set) var state: State
    private var subscriptions: [Subscription<State>]
    private var effects: [AnyEffect]
    
    public init(initialState state: State, effects: [AnyEffect] = []) {
        self.state = state
        self.effects = effects
        subscriptions = []
    }
    
    public func subscribe<S: StoreSubscriber>(_ subscriber: S, onlyOnChange keyPaths: [PartialKeyPath<State>]) {
        var flag = true
        let sub = Subscription<State>(subscriber: subscriber) { newState, oldState in
            var state: State?
            
            for keyPath in keyPaths {
                guard !flag else {
                    flag = false
                    return newState
                }
                
                guard
                    let newSubState = newState[keyPath: keyPath] as? AnyStateType,
                    let oldSubState = oldState?[keyPath: keyPath] as? AnyStateType else {
                        continue
                }
                
                if !newSubState.isEqual(prototype: oldSubState) {
                    state = newState
                }
//                newSubState?._actionType == oldSubState?._actionType
                
                
                
//                isEqual(_type, subState, subState)
                
//                if newState[keyPath: keyPath] != oldState?[keyPath: keyPath] {
//                    state = newState
//                }
            }
            
            return state
//            return newState[keyPath: keyPath] != oldState?[keyPath: keyPath] ? newState : nil
        }
        subscriptions.append(sub)
        sub.newState(state, oldState: nil)
    }
    
    public func subscribe<S: StoreSubscriber>(_ subscriber: S) {
        let sub = Subscription<State>(subscriber: subscriber) { newState, oldState  in
            return newState != oldState ? newState : nil
        }
        subscriptions.append(sub)
        sub.newState(state, oldState: nil)
    }
    
    public func dispatch(_ action: AnyAction) {
        DispatchQueue.main.async {
            self._defaultDispatch(action)
        }
    }
    
    public func dispatch(_ actionProducer: (State, Store<State>) -> AnyAction?) {
        guard let action = actionProducer(state, self) else {
            return
        }
        
        dispatch(action)
    }
    
    public func dispatch(_ actionProducer: (State, Store, @escaping (AnyAction) -> Void) -> Void, _ handler: @escaping () -> Void) {
        actionProducer(state, self) { [weak self] action in
            self?.dispatch(action)
            handler()
        }
    }
    
    public func _defaultDispatch(_ action: AnyAction) {
        if effects.count > 0 {
            effects.forEach {
                if let _action = $0.anyEffect(self, action: action) as? State.Action {
                    self.swap(state.reduce(_action))
                }
            }
        }
        
        if let state = state.reduceAny(action) {
            swap(state)
        }
    }
    
    public func addSubscriber(_ handler: @escaping (State) -> Void) {
        let wrapper = SubscriptionWrapper<State>()
        wrapper.handler = handler
        subscribe(wrapper)
    }
    
    public func unsubscribe<S: StoreSubscriber>(_ subscriber: S) {
        var index: Int? = nil
        
        for (i, sub) in subscriptions.enumerated() {
            if let originalSub = sub.subscriber as? S,
                originalSub === subscriber {
                index = i
            }
        }
        
        if let index = index {
            subscriptions.remove(at: index)
        }
    }
    
    private func swap(_ newState: State) {
        let oldSate = state
        self.state = newState
        
        subscriptions.forEach { sub in
            sub.newState(self.state, oldState: oldSate)
        }
    }
}
