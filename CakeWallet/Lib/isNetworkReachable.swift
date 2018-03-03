//
//  isNetworkReachable.swift
//  CakeWallet
//
//  Created by Cake Technologies on 01.03.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation
import SystemConfiguration

func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
    let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
    
    return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
}
