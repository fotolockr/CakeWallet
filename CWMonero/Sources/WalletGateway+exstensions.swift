import Foundation
import CakeWalletLib

extension WalletGateway {
    public func makeConfigURL(for walletName: String) -> URL {
        let folderURL = makeDirURL(for: walletName)
        let filename = walletName + ".json"
        return folderURL.appendingPathComponent(filename)
    }
    
    public func makeURL(for walletName: String) -> URL {
        let folderURL = makeDirURL(for: walletName)
        return folderURL.appendingPathComponent(walletName)
    }
    
    public func makeDirURL(for walletName: String) -> URL {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: Self.path + "/" + walletName)
        }
        
        url.appendPathComponent("wallets")
        
        
        if !Self.path.isEmpty {
            url.appendPathComponent(Self.path)
        }
        
        url.appendPathComponent(walletName)
        var isDir: ObjCBool = true
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir.boolValue {
            try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            return url
        }
        
        return url
    }
}
