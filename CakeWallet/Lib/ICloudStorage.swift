import Foundation

enum ICloudStorageError: LocalizedError {
    case notEnabled
}

extension ICloudStorageError  {
     var errorDescription: String? {
        switch self {
        case .notEnabled:
            return "iCloud is not enabled for this app. Please go to settings iCloud to enable it"
        }
    }
}

final class ICloudStorage: CloudStorage {
    func isEnabled() -> Bool {
        return (try? getContainerUrl()) != nil
    }
    
    func getContainerUrl() throws -> URL {
        guard let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            throw ICloudStorageError.notEnabled
        }
        
        return containerUrl.appendingPathComponent("Documents")
    }
    
    func write(data: Data, to path: String) throws {
        let destination = try getContainerUrl().appendingPathComponent(path)
        let success = FileManager.default.createFile(atPath: destination.path, contents: data, attributes: nil)
        
        if !success {
            throw CloudStorageError.notUploaded
        }
    }
    
    func uploadFile(from url: URL, to path: String) throws {
        let destination = try getContainerUrl().appendingPathComponent(path)
        try FileManager.default.copyItem(at: url, to: destination)
    }
    
    func isFileExist(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func loadFile(withPath path: String, to url: URL) throws {
        let icloudSourceURL = try getContainerUrl().appendingPathComponent(path)
        try FileManager.default.copyItem(at: icloudSourceURL, to: url)
    }
    
    func getFilesList(for path: String) throws -> [URL] {
        let containerUrl = try getContainerUrl()
        
        return try FileManager.default.contentsOfDirectory(at: containerUrl, includingPropertiesForKeys: nil, options: [])
    }
}
