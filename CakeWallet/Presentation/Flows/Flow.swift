//
//  Flow.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

protocol Flow {
    associatedtype Route: RouteType
    typealias FinishHandler = VoidEmptyHandler
    var currentViewController: UIViewController { get }
    var finalHandler: FinishHandler { get set }
    
    func changeRoute(_ route: Route)
}
