//
//  MoneroRateTicker.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation
import Starscream

final class MoneroRateTicker: RateTicker {
    private(set) var rate: Double {
        didSet {
            emit(rate: rate)
        }
    }
    private var socket: WebSocket
    private var listeners: [RateListener]
    
    init() {
        
        // FIX-ME: Unnamed constant
        
        let url = URL(string: "wss://api.bitfinex.com/ws")!
        socket = WebSocket(url: url)
        rate = 0
        listeners = []
        config()
        connect()
    }
    
    deinit {
        socket.disconnect()
    }
    
    func add(listener: @escaping (Double) -> Void) {
        listeners.append(listener)
        listener(rate)
    }
    
    func connect() {
        DispatchQueue.global(qos: .background).async {
            self.socket.connect()
        }
    }
    
    private func emit(rate: Double) {
        listeners.forEach { $0(rate) }
    }
    
    private func config() {
        let event = [
            "event": "subscribe",
            "channel": "ticker",
            "pair": "XMRUSD"
        ]
        
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
                        self.rate = price
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
