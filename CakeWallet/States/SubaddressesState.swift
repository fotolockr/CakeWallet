import CakeWalletCore
import CakeWalletLib
import CWMonero

public struct SubaddressesState: StateType {
    public static func == (lhs: SubaddressesState, rhs: SubaddressesState) -> Bool {
        return lhs.subaddresses == rhs.subaddresses
        
    }
    
    public enum Action: AnyAction {
        case changed([Subaddress])
        case added([Subaddress])
    }
    
    public let subaddresses: [Subaddress]
    
    public init(subaddresses: [Subaddress]) {
        self.subaddresses = subaddresses
    }
    
    public func reduce(_ action: SubaddressesState.Action) -> SubaddressesState {
        switch action {
        case let .changed(subaddresses):
            return SubaddressesState(subaddresses: subaddresses)
        case let .added(subaddresses):
            return SubaddressesState(subaddresses: subaddresses)
        }
    }
}
