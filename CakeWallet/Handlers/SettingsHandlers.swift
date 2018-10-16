import CakeWalletLib
import CakeWalletCore
import LocalAuthentication

//public struct AuthenticationHandler: AsyncHandler {
//    public func handle(action: SettingsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
//        guard case let .authentication(pin) = action else { return }
//        
//        workQueue.async {
//            do {
//                let originPinCode = try KeychainStorageImpl.standart.fetch(forKey: .pinCode)
//                if originPinCode == pin {
//                    handler(AppState.Action.isAuthenticated)
//                } else {
//                    Dispatcher.standart.dispatch(AppState.Action.error(AuthenticationError.incorrectPassword))
//                }
//            } catch {
//                store.dispatch(ApplicationState.Action.changedError(error))
//            }
//        }
//    }
//}

public struct SetPinHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .setPin(pin, length) = action else { return nil }
        do {
            try KeychainStorageImpl.standart.set(value: pin, forKey: .pinCode)
            UserDefaults.standard.set(length.int, forKey: Configurations.DefaultsKeys.pinLength)
            return SettingsState.Action.pinSet
        } catch {
            return ApplicationState.Action.changedError(error)
        }
    }
}

public struct ChangeAutoSwitchHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .changeAutoSwitchNodes(isOn) = action else { return nil }
        UserDefaults.standard.set(isOn, forKey: Configurations.DefaultsKeys.autoSwitchNode)
        return SettingsState.Action.changeAutoSwitchNode(isOn)
    }
}

public struct ChangeBiometricAuthenticationHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .changeBiometricAuthentication(isAllowed, handler) = action else { return nil }
        
        if isAllowed {
            let localAuthenticationContext = LAContext()
            var authError: NSError?
            
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                let reasonString = NSLocalizedString("unlock_wallet", comment: "")
                localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                    UserDefaults.standard.set(success, forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
                    store.dispatch(SettingsState.Action.changedBiometricAuthentication(success))
                    handler(success)
                }
            }
            
            return nil
        }
        
        UserDefaults.standard.set(isAllowed, forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
        handler(isAllowed)
        return SettingsState.Action.changedBiometricAuthentication(isAllowed)
    }
}

public struct ChangeTransactionPriorityHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .changeTransactionPriority(priority) = action else { return nil }
        UserDefaults.standard.set(priority.rawValue, forKey: Configurations.DefaultsKeys.transactionPriority)
        return SettingsState.Action.changeTransactionPriority(priority)
    }
}

public struct ChangeCurrentNodeHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .changeCurrentNode(node) = action else { return nil }
        UserDefaults.standard.set(node.uri, forKey: Configurations.DefaultsKeys.nodeUri)
        UserDefaults.standard.set(node.login, forKey: Configurations.DefaultsKeys.nodeLogin)
        UserDefaults.standard.set(node.password, forKey: Configurations.DefaultsKeys.nodePassword)
        return SettingsState.Action.changeCurrentNode(node)
    }
}

public struct ChangeCurrentFiatHandler: Handler {
    public func handle(action: SettingsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .changeCurrentFiat(currency) = action else { return nil }
        UserDefaults.standard.set(currency.rawValue, forKey: Configurations.DefaultsKeys.currency)
        return SettingsState.Action.changedFiatCurrency(currency)
    }
}

