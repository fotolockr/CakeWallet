import Foundation

final class ICloudStorage: CloudStorage {
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
    
    func write(data: Data, to path: String) throws {
        let destination = containerUrl!.appendingPathComponent(path)
        let success = FileManager.default.createFile(atPath: destination.path, contents: data, attributes: nil)
        
        if !success {
            throw CloudStorageError.notUploaded
        }
    }
    
    func uploadFile(from url: URL, to path: String) throws {
        let destination = containerUrl!.appendingPathComponent(path)
        try FileManager.default.copyItem(at: url, to: destination)
    }
    
    func isFileExist(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func loadFile(withPath path: String, to url: URL) throws {
        let icloudSourceURL = containerUrl!.appendingPathComponent(path)
        try FileManager.default.copyItem(at: icloudSourceURL, to: url)
    }
    
    func getFilesList(for path: String) throws -> [URL] {
        guard let containerUrl = containerUrl else {
            return []
        }
        
        return try FileManager.default.contentsOfDirectory(at: containerUrl, includingPropertiesForKeys: nil, options: [])
    }
}
