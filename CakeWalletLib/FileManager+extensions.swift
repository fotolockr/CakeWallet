import Foundation

public enum FileManagerError: Error {
    case cannotFindWalletDir
}

extension FileManager {
    public var walletDirectory: URL? {
        return self.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("wallets")
    }
    
    public func createWalletDirectory(for name: String) throws -> URL {
        guard var url  = walletDirectory else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        url.appendPathComponent(name, isDirectory: true)
        
        var isDir: ObjCBool = true
        
        if !fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue {
            try createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    public func walletDirectory(for name: String) throws -> URL {
        guard var url  = walletDirectory else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        url.appendPathComponent(name, isDirectory: true)
        
        var isDir: ObjCBool = true
        
        guard fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue  else {
            throw FileManagerError.cannotFindWalletDir
        }
        
        return url
    }
}
