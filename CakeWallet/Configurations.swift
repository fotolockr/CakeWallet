//
//  Configurations.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation

final class Configurations {
    enum DefaultsKeys: Stringify {
        case nodeUri, nodeLogin, nodePassword, termsOfUseAccepted, currentWalletName,
             currentWalletType,  biometricAuthenticationOn, passwordIsRemembered, transactionPriority
        
        func stringify() -> String {
            switch self {
            case .nodeUri:
                return "node_uri"
            case .termsOfUseAccepted:
                return "terms_of_use_accepted"
            case .nodeLogin:
                return "node_login"
            case .nodePassword:
                return "node_password"
            case .currentWalletName:
                return "current_wallet_name"
            case .currentWalletType:
                return "current_wallet_type"
            case .biometricAuthenticationOn:
                return "biometric_authentication_on"
            case .passwordIsRemembered:
                return "pin_password_is_remembered"
            case .transactionPriority:
                return "saved_fee_priority"
            }
        }
    }
    
    static let defaultNodeUri = "node.moneroworld.com:18089"
}
