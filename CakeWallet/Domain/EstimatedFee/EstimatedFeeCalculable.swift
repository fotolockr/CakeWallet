//
//  EstimatedFeeCalculable.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol EstimatedFeeCalculable {
    func calculateEstimatedFee(forPriority priority: TransactionPriority) -> Promise<Amount>
}
