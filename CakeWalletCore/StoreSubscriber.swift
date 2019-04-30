import Foundation

public protocol AnyStoreSubscriber: class {
    func _onStateChange(_ state: Any)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreListenerState
    
    func onStateChange(_ state: StoreListenerState)
}

extension StoreSubscriber {
    public func _onStateChange(_ state: Any) {
        if let _state = state as? StoreListenerState {
            DispatchQueue.main.async { [weak self] in
                self?.onStateChange(_state)
            }
        }
    }
}

