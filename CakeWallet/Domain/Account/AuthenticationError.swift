////
////  AuthenticationError.swift
////  Wallet
////
////  Created by FotoLockr on 12/1/17.
////  Copyright © 2017 FotoLockr. All rights reserved.
////
//
import Foundation

enum AuthenticationError: Error {
    case incorrectPassword
    case exceededNumberOfFailedAuthorizations
}

