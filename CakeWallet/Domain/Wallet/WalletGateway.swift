//
//  WalletGateway.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

struct WalletLoadingCredentials {
    let name: String
    let password: String
}

struct WalletCreatingCredentials {
    let name: String
    let password: String
}

protocol WalletGateway: EmptyInitializable {
    static var prefixPath: String { get }
    static var type: WalletType { get }
    
    static func fetchWalletsList() -> Promise<[WalletDescription]>
    func create(withCredentials credentials: WalletCreatingCredentials) -> Promise<WalletProtocol>
    func load(withCredentials credentials: WalletLoadingCredentials) -> Promise<WalletProtocol>
    func recoveryWallet(withName name: String, andSeed seed: String, password: String) -> Promise<WalletProtocol>
    func remove(withName name: String, password: String) -> Promise<Void>
    func isExist(withName name: String) -> Bool
    func makePath(for walletName: String) -> String
}

extension WalletGateway {
    func makePath(for walletName: String) -> String {
        guard let dirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return Self.prefixPath + walletName
        }
        
        let path = dirUrl.path + Self.prefixPath + walletName
        var isDir: ObjCBool = true
        
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
            return try! FileManager.default.createWalletDirectory(for: walletName).path + "/" + walletName
        }
        
        return path
    }
}
