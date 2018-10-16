import Foundation

public protocol AnyAction {}
public protocol AnyPayload {}
public protocol HandlableAction: AnyAction {}

public struct Action<Action, Payload>: AnyAction where Action: AnyAction, Payload: AnyPayload {
    public let action: Action
    public let payload: Payload
    
    public init(action: Action, payload: Payload) {
        self.action = action
        self.payload = payload
    }
}

public protocol AnyHandler {
    var AnyAction: AnyAction.Type { get }
    func handle(anyAction: AnyAction, store: AnyStore) -> AnyAction?
}

public protocol Handler: AnyHandler {
    associatedtype Action: AnyAction
    associatedtype StoreState: StateType
    func handle(action: Action, store: Store<StoreState>) -> AnyAction?
}

public protocol AnyAsyncHandler: AnyHandler {
    func handle(anyAction: AnyAction, store: AnyStore, handler: @escaping (AnyAction?) -> Void)
}

public protocol AsyncHandler: AnyAsyncHandler {
    associatedtype Action: AnyAction
    associatedtype StoreState: StateType
    func handle(action: Action, store: Store<StoreState>, handler: @escaping (AnyAction?) -> Void)
}

extension Handler {
    public var AnyAction: AnyAction.Type {
        return Action.self
    }
    
    public func handle(anyAction: AnyAction, store: AnyStore) -> AnyAction? {
        if
            let action = anyAction as? Action,
            let store = store as? Store<StoreState> {
            return handle(action: action, store: store)
        }
        
        return nil
    }
}

extension AsyncHandler {
    public var AnyAction: AnyAction.Type {
        return Action.self
    }
    
    public func handle(anyAction: AnyAction, store: AnyStore, handler: @escaping (AnyAction?) -> Void) {
        if
            let action = anyAction as? Action,
            let store = store as? Store<StoreState> {
            self.handle(action: action, store: store, handler: handler)
        }
    }
    
    public func handle(anyAction: AnyAction, store: AnyStore) -> AnyAction? {
        if
            let action = anyAction as? Action,
            let store = store as? Store<StoreState> {
            handle(action: action, store: store) { _ in }
            return nil
        }
        
        return nil
    }
}

