import UIKit

final class NewWalletViewController: BaseViewController<NewWalletView> {
    weak var signUpFlow: SignUpFlow?
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(signUpFlow: SignUpFlow, restoreWalletFlow: RestoreWalletFlow) {
        self.signUpFlow = signUpFlow
        self.restoreWalletFlow = restoreWalletFlow
        super.init()
    }
    
    override func configureBinds() {
        contentView.createWallet.addTarget(self, action: #selector(createWallet), for: .touchUpInside)
        contentView.recoveryWallet.addTarget(self, action: #selector(recoveryWallet), for: .touchUpInside)
    }
    
    @objc
    private func createWallet() {
        signUpFlow?.change(route: .createWallet)
    }
    
    @objc
    private func recoveryWallet() {
        restoreWalletFlow?.change(route: .root)
    }
}
