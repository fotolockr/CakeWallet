import UIKit
import CakeWalletLib
import CakeWalletCore

func generateMasterPassword(keychain: KeychainStorage = KeychainStorageImpl.standart) {
    let newPassword = UUID().uuidString
    
    do {
        try keychain.set(value: newPassword, forKey: .masterPassword)
        UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.masterPassword)
    } catch {
        print(error)
    }
}
