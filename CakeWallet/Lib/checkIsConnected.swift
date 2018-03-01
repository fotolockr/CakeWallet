//
//  checkIsConnected.swift
//  CakeWallet
//
//  Created by Mykola Misiura on 01.03.2018.
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import Foundation
import SystemConfiguration

func checkIsConnected(withHost host: String) -> Bool {
    guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return false }
    
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    
    if !isNetworkReachable(with: flags) {
        return false
    }
    
    return true
}
