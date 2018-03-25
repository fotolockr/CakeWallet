//
//  EstimatedFeeCalculable.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol EstimatedFeeCalculable {
    func calculateEstimatedFee(forPriority priority: TransactionPriority) -> Promise<Amount>
}
