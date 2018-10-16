import Foundation

public protocol AnyStateType {
    func isEqual(prototype: AnyStateType) -> Bool
    func reduceAny(_ action: AnyAction) -> Self?
}
