import Foundation

protocol CloudStorage {
    func uploadFile(from url: URL, to path: String) throws
    func write(data: Data, to path: String) throws
    func isFileExist(at url: URL) -> Bool
    func loadFile(withPath path: String, to url: URL) throws
    func getFilesList(for path: String) throws -> [URL]
}
