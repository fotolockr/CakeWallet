import Foundation

extension Store {
    public var _StateType: AnyStateType.Type {
        return State.self
    }
    
    public var _state: AnyStateType {
        return state
    }
        
    public func dispatch<Action>(_ action: Action) where Action : AnyAction {
        if let action = action as? State.Action {
            dispatch(action)
        }
    }
    
    public func dispatch(_ actionProducer: (AnyStore, AnyStateType) -> AnyAction?, _ handler: (() -> Void)?) {
        guard let action = actionProducer(self, self.state) else {
            return
        }
        
        if let _action = action as? State.Action {
            _defaultDispatch(_action)
        }
        
        handler?()
    }
    
//    public func dispatch(_ actionProducer: @escaping (State, Dispatcher, (State.Action) -> Void) -> Void) {
//        self.dispatch(actionProducer, nil)
//    }
    
    public func _anyDefaultDispatch(_ action: AnyAction) {
        if let action = action as? State.Action {
            _defaultDispatch(action)
        }
    }
}
