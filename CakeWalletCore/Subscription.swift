import Foundation

struct Subscription<State> {
    let subscriber: AnyStoreSubscriber
    var filter: ((State, State?) -> State?)?
    
    public init(subscriber: AnyStoreSubscriber, filter: ((State, State?) -> State?)? = nil) {
        self.subscriber = subscriber
        self.filter = filter
    }
    
    func newState(_ newState: State, oldState: State?) {
        if let state = filter?(newState, oldState) {
            subscriber._onStateChange(state)
        }
    }
}
