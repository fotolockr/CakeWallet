//
//  MoneroWalletGateway.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

private let isRecoveryKey = "monero_wallet_is_recovery"

final class MoneroWalletGateway: WalletGateway {
    static let prefixPath = "/Monero/"
    static let type: WalletType = .monero
    
    static func fetchWalletsList() -> Promise<[WalletDescription]> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                guard
                    let docsUrl = FileManager.default.walletDirectory,
                    let walletsDirs = try? FileManager.default.contentsOfDirectory(atPath: docsUrl.path) else {
                        fulfill([])
                        return
                }
                
                fulfill(walletsDirs.map { WalletDescription(name: $0) })
            }
        }
    }
    
    func create(withCredentials credentials: WalletCreatingCredentials) -> Promise<WalletProtocol> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let moneroAdapter = MoneroWalletAdapter()!
                    let isRecovery = false
                    try moneroAdapter.generate(withPath: self.makePath(for: credentials.name), andPassword: credentials.password)
                    try moneroAdapter.save()
                    moneroAdapter.setIsRecovery(isRecovery)
                    let moneroWallet = MoneroWalletType(
                        moneroAdapter: moneroAdapter,
                        password: credentials.password,
                        isRecovery: isRecovery, keychainStorage: try! container.resolve() as KeychainStorage)
                    fulfill(moneroWallet)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func load(withCredentials credentials: WalletLoadingCredentials) -> Promise<WalletProtocol> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let moneroAdapter = MoneroWalletAdapter()!
                    try moneroAdapter.loadWallet(withPath: self.makePath(for: credentials.name), andPassword: credentials.password)
                    let isRecovery = self.getIsRecovery(for: credentials.name) ? true : false
                    moneroAdapter.setIsRecovery(isRecovery)
                    let moneroWallet = MoneroWalletType(moneroAdapter: moneroAdapter, password: credentials.password, isRecovery: isRecovery, keychainStorage: try! container.resolve() as KeychainStorage)
                    fulfill(moneroWallet)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func recoveryWallet(withName name: String, andSeed seed: String, password: String) -> Promise<WalletProtocol> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let moneroAdapter = MoneroWalletAdapter()!
                    try moneroAdapter.recovery(at: self.makePath(for: name), mnemonic: seed)
                    self.saveIsRecovery(for: name)
                    try moneroAdapter.setPassword(password)
                    let moneroWallet = MoneroWalletType(moneroAdapter: moneroAdapter, password: password, isRecovery: true, keychainStorage: try! container.resolve() as KeychainStorage)
                    fulfill(moneroWallet)
                } catch {
                    self.remove(withName: name, password: password)
                        .then { _ in reject(error) }
                        .catch { _ in reject(error) }
                }
            }
        }
    }
    
    func isExist(withName name: String) -> Bool {
        guard let _ = try? FileManager.default.walletDirectory(for: name) else {
            return false
        }
        
        return true
    }
    
    func remove(withName name: String, password: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    let walletDir = try FileManager.default.walletDirectory(for: name)
                    try FileManager.default.removeItem(atPath: walletDir.path)
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private func saveIsRecovery(for name: String) {
        UserDefaults.standard.set(true, forKey: isRecoveryKey(for: name))
    }
    
    private func getIsRecovery(for name: String) -> Bool {
        return UserDefaults.standard.bool(forKey: isRecoveryKey(for: name))
    }
    
    private func isRecoveryKey(for name: String) -> String {
        return "\(isRecoveryKey)_\(name)"
    }
}
