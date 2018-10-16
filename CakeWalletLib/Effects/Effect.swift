import Foundation

//public protocol AnyEffect {
//    func anyEffect(_ store: AnyStore, action: AnyAction, dispatcher: Dispatcher) -> AnyAction?
//}
//
//public protocol Effect: AnyEffect {
//    associatedtype S: Store
//    associatedtype A: AnyAction
//    func effect(_ store: S, action: A, dispatcher: Dispatcher) -> AnyAction?
//}
//
//extension Effect {
//    public func anyEffect(_ store: AnyStore, action: AnyAction, dispatcher: Dispatcher) -> AnyAction? {
//        guard let store = store as? S, let _action = action as? A else {
//            return action
//        }
//        
//        return effect(store, action: _action, dispatcher: dispatcher)
//    }
//}
