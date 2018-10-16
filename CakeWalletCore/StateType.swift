import Foundation

public protocol StateType: AnyStateType, Equatable  {
    associatedtype Action: AnyAction
    func reduce(_ action: Action) -> Self
}

extension StateType {
    public func isEqual(prototype: AnyStateType) -> Bool {
        if let prototype = prototype as? Self {
            return self == prototype
        }
        
        return false
    }
    
    public func reduceAny(_ action: AnyAction) -> Self? {
        if let action = action as? Action {
           return reduce(action)
        }
        
        return nil
    }
}
