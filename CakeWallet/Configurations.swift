//
//  Configurations.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

final class Configurations {
    enum DefaultsKeys: Stringify {
        case nodeUri, nodeLogin, nodePassword, termsOfUseAccepted, currentWalletName,
             currentWalletType,  biometricAuthenticationOn, passwordIsRemembered, transactionPriority,
             currency
        
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
            case .currency:
                return "currency"
            }
        }
    }
    
    static let defaultNodeUri = "opennode.xmr-tw.org:18089"
    static let defaultCurreny = Currency.usd
    static var termsOfUseUrl: URL? {
        return Bundle.main.url(forResource: "Terms_of_Use", withExtension: "rtf")
    }
    
    static let donactionAddress = "43gN49UjHNdXDgkcWHTxceHNjXBxcKsReSNThGwzHVavHeZ4SSxSCPT8EpD5cbwAWqEqFQw12rsyTJbKGbeXo43SVpPXZ2W"
}
