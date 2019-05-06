import Foundation
import CakeWalletLib
import CakeWalletCore
import ZIPFoundation
import CryptoSwift
import CWMonero
import SwiftyJSON

// FIXME: FIXME FIXME FIRSTLY!!!!!!!!!!!!!!!!!!!!!!!!!

final class BackupServiceImpl: BackupService {
    
    private static let salt = AppSecrets.backupSalt
    private static let keychainSalt = AppSecrets.keychainSalt
    private static var defaultBackupName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateFormatted = dateFormatter.string(from: Date())
        return String(format: "%@_%@", "backup", dateFormatted)
    }
    
    let fileManager: FileManager
    let keychain: KeychainStorage
    
    init(fileManager: FileManager = FileManager.default, keychain: KeychainStorage = KeychainStorageImpl.standart) {
        self.fileManager = fileManager
        self.keychain = keychain
    }
    
    func export(withPassword password: String) throws -> Data {
        let documentsURL = try getDocumentsURL()
        let tmpFilename = "___tmp_backup_import.zip"
        let tmpURL = documentsURL.appendingPathComponent(tmpFilename)
        
        if fileManager.fileExists(atPath: tmpURL.path) {
            try fileManager.removeItem(at: tmpURL)
        }
        
        let walletsDirURL = documentsURL.appendingPathComponent("wallets")
        try fileManager.zipItem(at: walletsDirURL, to: tmpURL)
        
        if let archive = Archive(url: tmpURL, accessMode: .update) {
            let keychainData = try encrypt(data: exportKeychainDump(), withPassword: password, andSalt: BackupServiceImpl.keychainSalt) as NSData
            let keychainSize = UInt32(keychainData.length)
            let userSettingsData = try exportUserSettings() as NSData
            let userSettingsSize = UInt32(userSettingsData.length)
            
            try archive.addEntry(with: "keychain.json", type: .file, uncompressedSize: keychainSize, provider: { (position, size) -> Data in
                return (keychainData as Data)
            })
            
            try archive.addEntry(with: "user_settings.json", type: .file, uncompressedSize: userSettingsSize, provider: { (position, size) -> Data in
                return (userSettingsData as Data)
            })
            
            let adressBookURL = documentsURL.appendingPathComponent("address_book.json")
            
            if
                fileManager.fileExists(atPath: adressBookURL.path),
                let addressBookData = NSData(contentsOf: adressBookURL) {
                let addressBookSize = UInt32(addressBookData.length)
                try archive.addEntry(with: adressBookURL.lastPathComponent, type: .file, uncompressedSize: addressBookSize, provider: { (position, size) -> Data in
                    return (addressBookData as Data)
                })
            }
        }
        
        let encrypted = try encrypt(at: tmpURL, withPassword: password, andSalt: BackupServiceImpl.salt)
        try fileManager.removeItem(at: tmpURL)
        
        return encrypted
    }
    
    func export(withPassword password: String, to storage: CloudStorage, filename: String = BackupServiceImpl.defaultBackupName) throws {
        let data = try export(withPassword: password)
        try storage.write(data: data, to: filename)
    }
    
    func export(withPassword password: String, to url: URL) throws {
        let data = try export(withPassword: password)
        try data.write(to: url)
    }
    
    func exportToTmpFile(withPassword password: String, filename: String = BackupServiceImpl.defaultBackupName) throws -> URL {
        let tmpDirURL = try getTmpDirecroryURL()
        let fileURL = tmpDirURL.appendingPathComponent(filename)
        try export(withPassword: password, to: fileURL)
        return fileURL
    }
    
    func `import`(from url: URL, withPassword password: String) throws {
        let decrypted = try decrypt(at: url, withPassword: password, andSalt: BackupServiceImpl.salt)
        let tmpFilename = "___tmp_backup_import.zip"
        let tmpDirectoryURL = try getTmpDirecroryURL()
        let tmpURL = tmpDirectoryURL.appendingPathComponent(tmpFilename)
        fileManager.createFile(atPath: tmpURL.path, contents: decrypted, attributes: nil)
        let documentsURL = try getDocumentsURL()
        try fileManager.unzipItem(at: tmpURL, to: documentsURL)
        let keychainDumpURL = documentsURL.appendingPathComponent("keychain.json")
        try importKeychain(from: keychainDumpURL, withPassword: password)
        try fileManager.removeItem(at: tmpURL)
        try fileManager.removeItem(at: keychainDumpURL)
        let userSettingsURL = documentsURL.appendingPathComponent("user_settings.json")
        try importUserSettings(from: userSettingsURL)
        try fileManager.removeItem(at: userSettingsURL)
    }
    
    func exportKeychainDump() throws -> Data {
        let wallets = MoneroWalletGateway.fetchWalletsList() // fixme for multi wallet types
        let walletsInfo = try wallets.map { wallet -> [String: String] in
            let password = try keychain.fetch(forKey: .walletPassword(wallet))
            let seed = try keychain.fetch(forKey: .seed(wallet))
            
            return [
                "name": wallet.name,
                "type": wallet.type.string(),
                "password": password,
                "seed": seed
            ]
        }
        
        let pin = try keychain.fetch(forKey: .pinCode)
        let masterPassword = try keychain.fetch(forKey: .masterPassword)
        let json = JSON(["pin": pin,
                         "master_password": masterPassword,
                         "wallets": walletsInfo])
        
        return try json.rawData()
    }
    
    func exportKeychainDump(to url: URL) throws {
        let wallets = MoneroWalletGateway.fetchWalletsList() // fixme for multi wallet types
        let walletsInfo = try wallets.map { wallet -> [String: String] in
            let password = try keychain.fetch(forKey: .walletPassword(wallet))
            let seed = try keychain.fetch(forKey: .seed(wallet))
            
            return [
                "name": wallet.name,
                "type": wallet.type.string(),
                "password": password,
                "seed": seed
            ]
        }
        
        let pin = try keychain.fetch(forKey: .pinCode)
        let masterPassword = try keychain.fetch(forKey: .masterPassword)
        let json = JSON(["pin": pin,
                         "master_password": masterPassword,
                         "wallets": walletsInfo])
        
        try json.rawData().write(to: url)
    }
    
    func importKeychain(from url: URL, withPassword password: String, andSalt salt: String = BackupServiceImpl.keychainSalt) throws {
        let data = try decrypt(at: url, withPassword: password, andSalt: salt)
        let json = try JSON(data: data)
        
        try json["wallets"].arrayValue.forEach { json in
            let name = json["name"].stringValue
            let typeRaw = json["type"].stringValue
            let password = json["password"].stringValue
            let seed = json["seed"].stringValue
            
            guard let type = WalletType(from: typeRaw) else {
                return
            }
            
            let index = WalletIndex(name: name, type: type)
            try keychain.set(value: password, forKey: .walletPassword(index))
            try keychain.set(value: seed, forKey: .seed(index))
        }
        
        let pin = json["pin"].stringValue
        let masterPassword = json["master_password"].stringValue
        try keychain.set(value: pin, forKey: .pinCode)
        try keychain.set(value: masterPassword, forKey: .masterPassword)
    }
    
    func exportUserSettings() throws -> Data {
        let currentWalletName = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentWalletName) ?? ""
        let walletsDirectoryPathMigrated = UserDefaults.standard.bool(forKey:   Configurations.DefaultsKeys.walletsDirectoryPathMigrated)
        let isMasterPasswordSet = UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.masterPassword)
        let dic = [
            Configurations.DefaultsKeys.currentWalletName.string(): currentWalletName,
            Configurations.DefaultsKeys.walletsDirectoryPathMigrated.string(): walletsDirectoryPathMigrated,
            Configurations.DefaultsKeys.masterPassword.string(): isMasterPasswordSet] as [String : Any]
        let json = JSON(dic)
        
        return try json.rawData()
    }
    
    func importUserSettings(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let json = try JSON(data: data)
        let walletName = json[Configurations.DefaultsKeys.currentWalletName.string()].stringValue
        let walletsDirectoryPathMigrated = json[Configurations.DefaultsKeys.walletsDirectoryPathMigrated.string()].stringValue
        let isMasterPasswordSet = json[Configurations.DefaultsKeys.masterPassword.string()].stringValue
        UserDefaults.standard.set(walletName, forKey: Configurations.DefaultsKeys.currentWalletName)
        UserDefaults.standard.set(walletsDirectoryPathMigrated, forKey: Configurations.DefaultsKeys.walletsDirectoryPathMigrated)
        UserDefaults.standard.set(isMasterPasswordSet, forKey: Configurations.DefaultsKeys.masterPassword)
    }
    
    private func encrypt(at url: URL, withPassword password: String, andSalt salt: String) throws -> Data {
        let data = try Data(contentsOf: url)
        let cipher = try makeCipher(with: password, andSalt: salt)
        
        return try Data(bytes: cipher.encrypt(data))
    }
    
    private func encrypt(data: Data, withPassword password: String, andSalt salt: String) throws -> Data {
        let cipher = try makeCipher(with: password, andSalt: salt)
        
        return try Data(bytes: cipher.encrypt(data))
    }
    
    private func decrypt(at url: URL, withPassword password: String, andSalt salt: String) throws -> Data {
        let data = try Data(contentsOf: url)
        let cipher = try makeCipher(with: password, andSalt: salt)
        
        return try Data(bytes: cipher.decrypt(data))
    }
    
    private func makeCipher(with password: String, andSalt salt: String) throws -> Blowfish {
        let password = Array(password.utf8) as Array<UInt8>
        let salt = Array(salt.utf8) as Array<UInt8>
        let key = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, variant: .sha256).calculate()
        return try Blowfish(key: key, padding: .pkcs7)
    }
    
    private func getWalletsDirectoryURL() throws -> URL {
        let url = try getDocumentsURL().appendingPathComponent("wallets")
        
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    private func getTmpDirecroryURL() throws -> URL {
        let url = try getDocumentsURL().appendingPathComponent("tmp")
        
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    private func getDocumentsURL() throws -> URL {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw BackupError.cannotFindDocumentDirectory
        }
        
        return URL(fileURLWithPath: path, isDirectory: true)
    }
}
