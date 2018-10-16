import Foundation

public protocol StoreType: AnyStore {
    associatedtype State: StateType
    typealias ActionProducer = (State, Self) -> AnyAction?
    typealias AsyncActionProducer = (State, Self, @escaping (AnyAction) -> Void) -> Void
    var state: State { get }
    
    func subscribe<S: StoreSubscriber>(_ subscriber: S, onlyOnChange keyPaths: [PartialKeyPath<State>])
    func subscribe<S: StoreSubscriber>(_ subscriber: S)
    
    func dispatch(_ actionProducer: ActionProducer)
    func dispatch(_ actionProducer: AsyncActionProducer, _ handler: @escaping () -> Void)
}
