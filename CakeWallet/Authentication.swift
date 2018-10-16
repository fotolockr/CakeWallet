import Foundation
import CakeWalletLib
import LocalAuthentication

protocol Authentication {
    func authenticate(pin: String, handler: @escaping (Result<Void>) -> Void)
    func biometricAuthentication(handler:  @escaping (Result<Void>) -> Void)
}

private(set) var biometricIsShown = false

final class AuthenticationImpl: Authentication {
    func authenticate(pin: String, handler: @escaping (Result<Void>) -> Void) {
        workQueue.async {
            do {
                let originPinCode = try KeychainStorageImpl.standart.fetch(forKey: .pinCode)
                if originPinCode == pin {
                    handler(Result.success(()))
                } else {
                    handler(Result.failed(AuthenticationError.incorrectPassword))
                }
            } catch {
                handler(Result.failed(error))
            }
        }
    }
    
    func biometricAuthentication(handler:  @escaping (Result<Void>) -> Void) {
        return self.authenticationWithLA(handler: handler)
    }
    
    func authenticationWithLA(handler: @escaping (Result<Void>) -> Void) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = NSLocalizedString("use_pin_password", comment: "")
        var authError: NSError?
        let reasonString = NSLocalizedString("unlock_wallet", comment: "")
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            biometricIsShown = true
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                biometricIsShown = false
                
                if success {
                    handler(.success(()))
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    
                    handler(.failed(error))
                }
            }
        } else {
            biometricIsShown = false
            
            guard let error = authError else {
                return
            }
            
            handler(.failed(error))
        }
    }
}
