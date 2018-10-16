import UIKit

final class NewWalletViewController: BaseViewController<NewWalletView> {
    weak var signUpFlow: SignUpFlow?
    
    init(signUpFlow: SignUpFlow) {
        self.signUpFlow = signUpFlow
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
        signUpFlow?.change(route: .restore)
    }
}
