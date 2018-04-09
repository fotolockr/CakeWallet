//
//  checkIsConnected.swift
//  CakeWallet
//
//  Created by Cake Technologies on 01.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit
import SwiftSocket

private let nodesPingQueue = DispatchQueue.init(
    label: "io.cakewallet.nodesPingQueue",
    qos: .default,
    attributes: .concurrent)

func checkConnectionAsync(toAddress address: String, port: Int32) -> Promise<Bool> {
    return Promise { fulfill, reject in
        nodesPingQueue.async {
            let client = TCPClient(address: address, port: port)
            switch client.connect(timeout: 3) {
            case .success:
                client.close()
                fulfill(true)
            case .failure(_):
                client.close()
                fulfill(false)
            }
        }
    }
}

func checkConnectionSync(toUri uri: String) -> Bool {
    let comp = uri.components(separatedBy: ":")
    guard let address = comp.first, let port = Int32(comp[1]) else {
        return false
    }
    
    let client = TCPClient(address: address, port: port)
    switch client.connect(timeout: 2) {
    case .success:
        client.close()
        return true
    case .failure(_):
        client.close()
        return false
    }
}
