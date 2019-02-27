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
        
        contentView.restoreFromKeysCard.button.addTarget(self, action: #selector(fromKeys), for: .touchUpInside)
        contentView.restoreFromSeedCard.button.addTarget(self, action: #selector(fromSeed), for: .touchUpInside)
    }
    
    @objc
    private func fromSeed() {
        restoreWalletFlow?.change(route: .fromSeedWalletName)
    }
    
    @objc
    private func fromKeys() {
        restoreWalletFlow?.change(route: .fromKeysWalletName)
    }
}
