import Foundation
import SwiftKeychainWrapper

public protocol KeychainStorage {
    func set(value: String, forKey key: KeychainKey) throws
    func fetch(forKey key: KeychainKey) throws -> String
    func remove(forKey key: KeychainKey) throws
}
