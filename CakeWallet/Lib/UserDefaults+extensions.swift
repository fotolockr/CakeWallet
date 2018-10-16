import Foundation
import CakeWalletLib

extension UserDefaults {
    func set(_ value: Any?, forKey key: Stringify) {
        self.set(value, forKey: key.string())
    }
    
    func string(forKey key: Stringify) -> String? {
        return self.string(forKey: key.string())
    }
    
    func bool(forKey key: Stringify) -> Bool {
        return self.bool(forKey: key.string())
    }
    
    func integer(forKey key: Stringify) -> Int {
        return self.integer(forKey: key.string())
    }
}
