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
import Socket
import SwiftyJSON
import Alamofire

let nodesPingQueue = DispatchQueue.init(
    label: "io.cakewallet.nodesPingQueue",
    qos: .default,
    attributes: .concurrent)
private let defaultTimeout: TimeInterval = 3

private let alamofireManager: SessionManager = {
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.timeoutIntervalForRequest = defaultTimeout
    return Alamofire.SessionManager(configuration: sessionConfiguration)
}()

func checkConnectionAsync(toAddress address: String, port: Int32) -> Promise<Bool> {
    return Promise { fulfill, reject in
        nodesPingQueue.async {
            do {
                let socket = try Socket.create(family: .inet6, type: .stream, proto: .tcp)
                try socket.connect(to: address, port: port)
//                print("\(address):\(port) - \(socket.isConnected)")
                fulfill(socket.isConnected)
                socket.close()
            } catch {
                print("\(address):\(port)")
                print(error)
                fulfill(false)
            }
        }
    }
}

func checkConnectionSync(with settings: ConnectionSettings) -> Bool {
    let urlString = "http://\(settings.uri)/json_rpc"
    let requestBody: [String: Any] = [
        "jsonrpc": "2.0",
        "id": "0",
        "method": "get_info"
    ]
    var canConnect = false
    let sem = DispatchSemaphore(value: 0)
    alamofireManager.request(urlString, method: .post, parameters: requestBody, encoding: JSONEncoding.default, headers: nil)
        .authenticate(user: settings.login, password: settings.password)
        .responseJSON { res in
            switch res.result {
            case let .success(value):
                let json = JSON(value)
                canConnect = json["result"]["status"].stringValue.lowercased() == "OK".lowercased()
            case let .failure(error):
                print(error)
                break
            }

            sem.signal()
    }

    _ = sem.wait(timeout: DispatchTime.distantFuture)
    return canConnect
}
