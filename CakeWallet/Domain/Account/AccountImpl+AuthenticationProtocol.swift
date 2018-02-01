//
//  AccountImpl+AuthenticationProtocol.swift
//  CakeWallet
//
//  Created by FotoLockr on 30.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import PromiseKit
import LocalAuthentication

private let limitOfFailedAuthorizations = 5
private let banInterval: TimeInterval = 60
private var numberOfFailedAuthentication = 0

// MARK: AccountImpl + AuthenticationProtocol

extension AccountImpl: AuthenticationProtocol {
    func login(withPassword password: String) -> Promise<Void> {
        return authenticate(password: password)
            .then { return self.loadCurrentWallet() }
    }
    
    func authenticate(password: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            // FIX-ME: Incorrect implementation
            guard numberOfFailedAuthentication < limitOfFailedAuthorizations else {
                reject(AuthenticationError.exceededNumberOfFailedAuthorizations)
                
                if numberOfFailedAuthentication <= 10 {
                    let savedBanTime = UserDefaults.standard.double(forKey: "unban_time")
                    let banTime = savedBanTime <= 0 ? Date().timeIntervalSince1970 : savedBanTime
                    let newBanTime: TimeInterval = banTime + (banInterval * Double(numberOfFailedAuthentication))
                    UserDefaults.standard.set(newBanTime, forKey: "unban_time")
                }
                
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                guard
                    let savedPin = try? self.keychainStorage.fetch(forKey: .pinPassword),
                    password == savedPin else {
                        DispatchQueue.main.async {
                            numberOfFailedAuthentication += 1
                            reject(AuthenticationError.incorrectPassword)
                        }
                        return
                }
                
                DispatchQueue.main.async {
                    if numberOfFailedAuthentication != 0 {
                        numberOfFailedAuthentication = 0
                        UserDefaults.standard.set(0, forKey: "unban_time")
                    }
                    
                    fulfill(())
                }
            }
        }
    }
    
    func biometricAuthenticationIsAllow() -> Bool {
        return UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
    }
    
    func biometricAuthentication() -> Promise<Void> {
        return self.authenticationWithLA()
    }
    
    private func authenticationWithLA() -> Promise<Void> {
        return Promise { fulfill, reject in
            let localAuthenticationContext = LAContext()
            localAuthenticationContext.localizedFallbackTitle = "Use Pin password"
            var authError: NSError?
            let reasonString = "To unlock your wallet"
            
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                    if success {
                        fulfill(())
                    } else {
                        guard let error = evaluateError else {
                            return
                        }
                        
                        reject(error)
                    }
                }
            } else {
                guard let error = authError else {
                    return
                }
                
                reject(error)
            }
        }
    }
}

