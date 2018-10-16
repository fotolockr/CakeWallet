import CakeWalletCore
import CakeWalletLib

public struct SettingsState: StateType {
    public static func == (lhs: SettingsState, rhs: SettingsState) -> Bool {
        return lhs.isAuthenticated == rhs.isAuthenticated
            && lhs.isAuthenticated == rhs.isAuthenticated
            && lhs.transactionPriority == rhs.transactionPriority
            && rhs.node != nil
                ? lhs.node?.compare(with: rhs.node!) ?? false
                : lhs.node == nil
            && lhs.isAutoSwitchNodeOn == rhs.isAutoSwitchNodeOn
            && lhs.fiatCurrency == rhs.fiatCurrency
    }
    
    public enum Action: AnyAction {
        case pinSet
        case isAuthenticated
        case changeTransactionPriority(TransactionPriority)
        case changeCurrentNode(NodeDescription)
        case changeAutoSwitchNode(Bool)
        case changedFiatCurrency(FiatCurrency)
        case changedBiometricAuthentication(Bool)
    }
    
    public let isPinCodeInstalled: Bool
    public let isAuthenticated: Bool
    public let isBiometricAuthenticationAllowed: Bool
    public let transactionPriority: TransactionPriority
    public let node: NodeDescription?
    public let isAutoSwitchNodeOn: Bool
    public let fiatCurrency: FiatCurrency
    
    
    public init(isPinCodeInstalled: Bool, isAuthenticated: Bool, isBiometricAuthenticationAllowed: Bool, transactionPriority: TransactionPriority, node: NodeDescription?, isAutoSwitchNodeOn: Bool, fiatCurrency: FiatCurrency) {
        self.isPinCodeInstalled = isPinCodeInstalled
        self.isAuthenticated = isAuthenticated
        self.isBiometricAuthenticationAllowed = isBiometricAuthenticationAllowed
        self.transactionPriority = transactionPriority
        self.node = node
        self.isAutoSwitchNodeOn = isAutoSwitchNodeOn
        self.fiatCurrency = fiatCurrency
    }
    
    public func reduce(_ action: SettingsState.Action) -> SettingsState {
        switch action {
        case .pinSet:
            return SettingsState(isPinCodeInstalled: true, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case .isAuthenticated:
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: true, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case let .changeTransactionPriority(priority):
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: priority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case let .changeCurrentNode(node):
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case let .changeAutoSwitchNode(isAutoSwitchNodeOn):
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case let .changedFiatCurrency(fiatCurrency):
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isBiometricAuthenticationAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        case let .changedBiometricAuthentication(isAllowed):
            return SettingsState(isPinCodeInstalled: isPinCodeInstalled, isAuthenticated: isAuthenticated, isBiometricAuthenticationAllowed: isAllowed, transactionPriority: transactionPriority, node: node, isAutoSwitchNodeOn: isAutoSwitchNodeOn, fiatCurrency: fiatCurrency)
        }
    }
}
