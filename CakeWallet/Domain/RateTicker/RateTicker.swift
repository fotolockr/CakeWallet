//
//  RateTicker.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

protocol RateTicker {
    typealias RateListener = (Double) -> Void
    var rate: Double { get }
    
    func add(listener: @escaping  RateListener)
}

func convertXMRtoUSD(amount: String, rate: Double) -> String {
    let amountStr = amount.replacingOccurrences(of: ",", with: ".")
    
    guard let balance = Double(amountStr) else {
        return "00.00"
    }
    
    let result = balance * rate
    return String(format: "%.2f", result)
}

func convertUSDtoXMR(amount: String, rate: Double) -> String {
    let amountStr = amount.replacingOccurrences(of: ",", with: ".")
    
    guard let balance = Double(amountStr) else {
        return MoneroAmount(value: 0).formatted()
    }
    
    let result = balance / rate
    return String(format: "%f", result)
}
