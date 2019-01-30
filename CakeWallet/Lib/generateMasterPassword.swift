import UIKit

func generateMasterPassword() {
    let newPassword = UUID().uuidString
    UserDefaults.standard.set(newPassword, forKey: Configurations.DefaultsKeys.masterPassword)
}
