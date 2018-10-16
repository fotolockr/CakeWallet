import Foundation

public protocol AnyStore {
    var _StateType: AnyStateType.Type { get }
    var _state: AnyStateType { get }
    func dispatch(_ action: AnyAction)
    func _defaultDispatch(_ action: AnyAction)
}
