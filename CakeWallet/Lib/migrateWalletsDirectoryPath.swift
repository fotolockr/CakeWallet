import Foundation

func migrateWalletsDirectoryPath(fileManager: FileManager = FileManager.default, newWalletsDirectory: String, exclude: [String] = [".shared-ringdb"]) throws {
    guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return
    }
    
    let excludePaths = exclude + [newWalletsDirectory]
    let newWalletsDirectoryURL = URL(fileURLWithPath: path, isDirectory: true)
        .appendingPathComponent(newWalletsDirectory)
        .appendingPathComponent("monero") // Doing it for monero wallets
    
    if !fileManager.fileExists(atPath: newWalletsDirectoryURL.path) {
        try fileManager.createDirectory(at: newWalletsDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    let documentsURL = URL(fileURLWithPath: path, isDirectory: true)
    let content = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: []).filter { url in
        let index = excludePaths.firstIndex(of: url.lastPathComponent)
        return index == nil
    }
    
    try content.forEach { url in
        let destinationURL = newWalletsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.moveItem(at: url, to: destinationURL)
    }
}
