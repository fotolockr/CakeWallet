//
//  MoneroRateTicker.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation
import Starscream

final class MoneroRateTicker: RateTicker {
    private(set) var rate: Double {
        didSet {
            emit(rate: rate)
        }
    }
    private var rateRaw: Double
    private var socket: WebSocket
    private var listeners: [RateListener]
    private let account: CurrencySettingsConfigurable
    
    init(account: CurrencySettingsConfigurable) {
        self.account = account
        // FIX-ME: Unnamed constant
        
        let url = URL(string: "wss://api.bitfinex.com/ws")!
        socket = WebSocket(url: url)
        rate = 0
        rateRaw = 0
        listeners = []
        config()
        connect()
    }
    
    deinit {
        socket.disconnect()
    }
    
    func add(listener: @escaping (Currency, Double) -> Void) {
        listeners.append(listener)
        listener(account.currency, rate)
    }
    
    func connect() {
        DispatchQueue.global(qos: .background).async {
            self.socket.connect()
        }
    }
    
    private func emit(rate: Double) {
        listeners.forEach { $0(account.currency, rate) }
    }
    
    private func setRate(_ xmrusdRate: Double) {
        rateRaw = xmrusdRate
        
        account.rate()
            .then { currencyRate in
                self.rate = xmrusdRate * currencyRate
            }.catch { error in
                print(error)
        }
    }
    
    private func config() {
        let event = [
            "event": "subscribe",
            "channel": "ticker",
            "pair": "XMRUSD"
        ]
        
        account.subscribeOnRateChange { [weak self] currencyRate in
            if let rateRaw = self?.rateRaw {
                let rate = rateRaw * currencyRate
                self?.rate = rate
            }
        }
        
        socket.onText = { text in
            DispatchQueue.global(qos: .background).async {
                do {
                    guard
                        let data = text.data(using: .utf8),
                        let json = try JSONSerialization.jsonObject(with: data) as? [Double] else {
                            return
                    }
                    
                    let price = json[3]
                    
                    DispatchQueue.main.async {
                        self.setRate(price)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        socket.onConnect = {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: event)
                guard let json = String(data: jsonData, encoding: .utf8) else {
                    return
                }
                
                self.socket.write(string: json)
            } catch {
                print("JSONSerialization error: \(error.localizedDescription)")
            }
        }
        
        socket.onDisconnect = { error in
            if let error = error {
                print("MoneroRateTicker: Disconnected - \(error)")
            } else {
                print("MoneroRateTicker: Disconnected")
            }
        }
    }
}
