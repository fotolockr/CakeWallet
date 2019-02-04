import Foundation

protocol BackupService {
    func export(withPassword password: String) throws -> Data
    func `import`(from url: URL, withPassword password: String) throws
    func export(withPassword password: String, to storage: CloudStorage, filename: String) throws
    func export(withPassword password: String, to url: URL) throws
}
