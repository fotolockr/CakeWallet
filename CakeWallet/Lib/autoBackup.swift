import Foundation
import CakeWalletLib

func autoBackup(backupService: BackupService = BackupServiceImpl(), cloudStorage: CloudStorage = ICloudStorage(), keychain: KeychainStorage = KeychainStorageImpl.standart, filename: String = "auto_backup") {
    let queue = DispatchQueue(label: "com.fotolockr.cakewawllet.autobackup", qos: .utility)
    queue.async {
        do {
            guard let lastBackupDate = UserDefaults.standard.object(forKey: Configurations.DefaultsKeys.lastBackupDate.string()) as? Date else {
                try makeAutobackup(backupService: backupService, cloudStorage: cloudStorage)
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.day], from: lastBackupDate, to: now)
            
            if
                let diff = components.day,
                diff >= 1 {
                try makeAutobackup(backupService: backupService, cloudStorage: cloudStorage)
            }
        } catch {
            print("Auto backup error:\n\(error.localizedDescription)")
        }
    }
}

private func makeAutobackup(backupService: BackupService, cloudStorage: CloudStorage, keychain: KeychainStorage = KeychainStorageImpl.standart, filename: String = "auto_backup") throws {
    let now = Date()
    let masterPassword = try keychain.fetch(forKey: .masterPassword)
    try backupService.export(withPassword: masterPassword, to: cloudStorage, filename: filename)
    UserDefaults.standard.set(now, forKey: Configurations.DefaultsKeys.lastBackupDate.string())
}
