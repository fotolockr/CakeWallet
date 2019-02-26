import UIKit
import CakeWalletLib

final class RestoreRootVC: BaseViewController<RestoreRootView> {
    weak var signUpFlow: SignUpFlow?
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(signUpFlow: SignUpFlow, restoreWalletFlow: RestoreWalletFlow) {
        self.signUpFlow = signUpFlow
        self.restoreWalletFlow = restoreWalletFlow
        super.init()
    }
    
    override func configureBinds() {
        title = "Restore"
        
        contentView.restoreWalletTitle.text = "Restore from seed/keys"
        contentView.restoreWalletDescription.text = "Get back your wallet from seed/keys that you’ve saved to secure place."
        contentView.restoreWalletButtonText.text = "Next"
        contentView.restoreWalletButton.addTarget(self, action: #selector(restoreWallet), for: .touchUpInside)
        
        contentView.restoreAppTitle.text = "Restore app from backup file"
        contentView.restoreAppDescription.text = "You can restore the whole app from a backed-up file."
        contentView.restoreAppButtonText.text = "Next"
        contentView.restoreAppButton.addTarget(self, action: #selector(restoreApp), for: .touchUpInside)
    }
    
    @objc
    private func restoreWallet() {
        signUpFlow?.change(route: .setupPin({ [weak self] _ in
            self?.restoreWalletFlow?.change(route: .root)
        }))
    }
    
    @objc
    private func restoreApp() {
        signUpFlow?.change(route: .restoreFromCloud)
    }
}
