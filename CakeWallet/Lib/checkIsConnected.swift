//
//  checkIsConnected.swift
//  CakeWallet
//
//  Created by Cake Technologies on 01.03.2018.
//  Copyright © 2018 Cake Technologies. 
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
