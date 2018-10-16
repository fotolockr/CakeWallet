import Foundation

public final class SubscriptionWrapper<State: StateType>: StoreSubscriber {
    var handler: ((State) -> Void)?
    
    public func onStateChange(_ state: State) {
        handler?(state)
    }
}
