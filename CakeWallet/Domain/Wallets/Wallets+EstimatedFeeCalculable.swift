//
//  Wallets+EstimatedFeeCalculable.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

private let estimatedSizeOfDefaultTransaction = 13065
private var cachedFees: [TransactionPriority: Amount] = [:]

extension Wallets: EstimatedFeeCalculable {
    func calculateEstimatedFee(forPriority priority: TransactionPriority) -> Promise<Amount> {
        return Promise { fulfill, reject in
            if let fee = cachedFees[priority] {
                fulfill(fee)
                return
            }
            
            let connectionSettings = ConnectionSettings.loadSavedSettings()
            fetchFeePerKb(connectionSettings: connectionSettings)
                .then { feePerKb -> Void in
                    let kb = UInt64((estimatedSizeOfDefaultTransaction + 1023) / 1024) // Round to kb
                    let multiplier = self.getMultiplier(forPriority: priority)
                    let feeValue = kb * feePerKb * multiplier
                    let fee = MoneroAmount(value: feeValue)
                    cachedFees[priority] = fee
                    fulfill(fee)
                }.catch { error in
                    reject(error)
            }
        }
    }
    
    private func fetchFeePerKb(connectionSettings: ConnectionSettings) -> Promise<UInt64> {
        return Promise { fulfill, reject in
            let urlString = "http://\(connectionSettings.uri)/json_rpc"
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let requestBody = [
                "jsonrpc": "2.0",
                "id": "0",
                "method": "get_fee_estimate",
                "params": "{\"grace_blocks\":10}"
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                reject(error)
            }
            
            let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        reject(error)
                        return
                    }
                    
                    guard let data = data else {
                        fulfill(0)
                        return
                    }
                    
                    if
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let result = decoded["result"] as? [String: Any],
                        let fee = result["fee"] as? UInt64 {
                        fulfill(fee)
                    } else {
                        fulfill(0)
                    }
                } catch {
                    reject(error)
                }
            }
            
            connection.resume()
        }
    }
    
    private func getMultiplier(forPriority priority: TransactionPriority) -> UInt64 {
        switch priority {
        case .slow:
            return 1
        case .default:
            return 4
        case .fast:
            return 20
        case .fastest:
            return 166
        }
    }
}
