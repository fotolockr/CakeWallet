import UIKit
import CakeWalletLib
import CakeWalletCore

public final class MoneroWalletGateway: WalletGateway {
    public static var path: String {
        return "monero"
    }
    
    public static var type: WalletType {
        return .monero
    }
    
    public static func fetchWalletsList() -> [WalletIndex] {
        guard
            let walletsURL = FileManager.default.walletDirectory?.appendingPathComponent(path),
            let walletsDirs = try? FileManager.default.contentsOfDirectory(atPath: walletsURL.path) else {
                return []
        }
        
        let wallets = walletsDirs.map { name -> String? in
            var isDir = ObjCBool(false)
            let url = walletsURL.appendingPathComponent(name)
            let isExist = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            return isExist && isDir.boolValue ? name : nil
            }.compactMap({ $0 })
        
        return wallets.map { name -> WalletIndex? in
            guard name != ".shared-ringdb" else {
                return nil
            }
            
            return WalletIndex(name: name, type: .monero)
            }.compactMap({ $0 })
    }
    
    public init() {}
    
    public func create(withName name: String, andPassword password: String) throws -> Wallet {
        let moneroAdapter = MoneroWalletAdapter()!
        try moneroAdapter.generate(withPath: self.makeURL(for: name).path, andPassword: password)
        try moneroAdapter.save()
        let walletConfig = WalletConfig(isRecovery: false, date: Date(), url: self.makeConfigURL(for: name))
        try walletConfig.save()
        return MoneroWallet(moneroAdapter: moneroAdapter, config: walletConfig)
    }
    
    public func load(withName name: String, andPassword password: String) throws -> Wallet {
        let moneroAdapter = MoneroWalletAdapter()!
        let path = self.makeURL(for: name).path
        try moneroAdapter.loadWallet(withPath: path, andPassword: password)
        let walletConfig: WalletConfig
        
        do {
            walletConfig = try WalletConfig.load(from: self.makeConfigURL(for: name))
        } catch {
            if !FileManager.default.fileExists(atPath: self.makeConfigURL(for: name).path) {
                walletConfig = WalletConfig(isRecovery: false, date: Date(), url: self.makeConfigURL(for: name))
                try walletConfig.save()
            } else {
                throw error
            }
        }
        
        return MoneroWallet(moneroAdapter: moneroAdapter, config: walletConfig)
    }
    
    public func recoveryWallet(withName name: String, andSeed seed: String, password: String, restoreHeight: UInt64) throws -> Wallet {
        let moneroAdapter = MoneroWalletAdapter()!
        try moneroAdapter.recovery(at: self.makeURL(for: name).path, mnemonic: seed, andPassword: password, restoreHeight: restoreHeight)
//        try moneroAdapter.setPassword(password)
//        moneroAdapter.setRefreshFromBlockHeight(restoreHeight)
//        moneroAdapter.setIsRecovery(true)
//        try moneroAdapter.save()
        let walletConfig = WalletConfig(isRecovery: true, date: Date(), url: self.makeConfigURL(for: name))
        try walletConfig.save()
        return MoneroWallet(moneroAdapter: moneroAdapter, config: walletConfig, restoreHeight: restoreHeight)
    }
    
    public func recoveryWallet(withName name: String, publicKey: String, viewKey: String, spendKey: String, password: String, restoreHeight: UInt64) throws -> Wallet {
        let moneroAdapter = MoneroWalletAdapter()!
        try moneroAdapter.recoveryFromKey(at: self.makeURL(for: name).path, withPublicKey: publicKey, andPassowrd: password, andViewKey: viewKey, andSpendKey: spendKey, withRestoreHeight: restoreHeight)
//        try moneroAdapter.setPassword(password)
//        moneroAdapter.setRefreshFromBlockHeight(restoreHeight)
//        moneroAdapter.setIsRecovery(true)
//        try moneroAdapter.save()
        let walletConfig = WalletConfig(isRecovery: true, date: Date(), url: self.makeConfigURL(for: name))
        try walletConfig.save()
        return MoneroWallet(moneroAdapter: moneroAdapter, config: walletConfig, restoreHeight: restoreHeight)
    }
    
    public func remove(withName name: String) throws {
        guard let walletsDir = FileManager.default.walletDirectory else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        let walletDir = walletsDir.appendingPathComponent(MoneroWalletGateway.path)
            .appendingPathComponent(name)
        
        if FileManager.default.fileExists(atPath: walletDir.path) {
            try FileManager.default.removeItem(atPath: walletDir.path)
        }
    }
    
    public func fetchSeed(for wallet: WalletIndex) throws -> String {
        return try KeychainStorageImpl.standart.fetch(forKey: .seed(wallet))
    }
    
    public func isExist(withName name: String) -> Bool {
        guard let _ = try? FileManager.default.walletDirectory(for: name) else {
            return false
        }
        
        return true
    }
    
    public func removeCacheFile(for name: String) throws {
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cachePath = String(format: "%@/%@", name, name)
        let url = docDir.appendingPathComponent(cachePath)
        try FileManager.default.removeItem(atPath:  url.path)
    }
}

private let estimatedSizeOfDefaultTransaction = 2000000
private var cachedFees: [TransactionPriority: Amount] = [:]

extension MoneroWalletGateway {
    public func calculateEstimatedFee(forPriority priority: TransactionPriority, handler: ((Result<Amount>) -> Void)?) {
        //fixme
//        workQueue.async {
            if let fee = cachedFees[priority] {
                handler?(.success(fee))
                return
            }

            self.fetchFeePerKb() { result in
                switch result {
                case let .success(feePerKb):
                    let kb = UInt64((estimatedSizeOfDefaultTransaction + 1023) / 1024) // Round to kb
                    let multiplier = self.getMultiplier(forPriority: priority)
                    let feeValue = kb * feePerKb * multiplier
                    let fee = MoneroAmount(value: feeValue)
                    cachedFees[priority] = fee
                    handler?(.success(fee))
                case let .failed(error):
                    handler?(.failed(error))
                }
            }
//        }
    }

    private func fetchFeePerKb(handler: ((Result<UInt64>) -> Void)?) {
        let urlString = "http://opennode.xmr-tw.org:18089/json_rpc" // fixme
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
            handler?(.failed(error))
        }

        let connection = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    handler?(.failed(error))
                    return
                }

                guard let data = data else {
                    handler?(.success(0))
                    return
                }

                if
                    let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let result = decoded["result"] as? [String: Any],
                    let fee = result["fee"] as? UInt64 {
                    handler?(.success(fee))
                } else {
                    handler?(.success(0))
                }
            } catch {
                handler?(.failed(error))
            }
        }

        connection.resume()
    }

    private func getMultiplier(forPriority priority: TransactionPriority) -> UInt64 {
        switch priority {
        case .slow:
            return 1
        case .default:
            return 4
        case .fast:
            return 24
        case .fastest:
            return 960
        }
    }
}
