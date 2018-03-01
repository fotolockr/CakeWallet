////
////  AuthenticationError.swift
////  Wallet
////
////  Created by Cake Technologies 12/1/17.
////  Copyright © 2017 Cake Technologies. All rights reserved.
////
//
import Foundation

enum AuthenticationError: Error {
    case incorrectPassword
    case exceededNumberOfFailedAuthorizations
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectPassword:
            return NSLocalizedString("Incorrect Pin password", comment: "")
        case .exceededNumberOfFailedAuthorizations:
            return NSLocalizedString("Exceeded number of failed authorizations", comment: "")
        }
    }
}

