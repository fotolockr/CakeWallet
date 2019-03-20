import UIKit
import CakeWalletLib

final class RestoreVC: BaseViewController<RestoreView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let type: WalletType
    
    init(restoreWalletFlow: RestoreWalletFlow, type: WalletType = .monero) {
        self.restoreWalletFlow = restoreWalletFlow
        self.type = type
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore", comment: "")
        
        contentView.restoreFromSeedCard.button.addTarget(self, action: #selector(fromSeed), for: .touchUpInside)
        contentView.restoreFromKeysCard.button.addTarget(self, action: #selector(fromKeys), for: .touchUpInside)
    }
    
    @objc
    private func fromSeed() {
        restoreWalletFlow?.change(route: .recoverFromSeed)
    }
    
    @objc
    private func fromKeys() {
        restoreWalletFlow?.change(route: .recoverFromKeys)
    }
}
