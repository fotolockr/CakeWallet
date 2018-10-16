import UIKit
import CakeWalletLib
import CakeWalletCore

final class CreateWalletViewController: BaseViewController<CreateWalletView> {
    weak var signUpFlow: SignUpFlow?
    let store: Store<ApplicationState>
    private var name: String {
        return contentView.nameTextField.text ?? ""
    }
    
    init(signUpFlow: SignUpFlow, store: Store<ApplicationState>) {
        self.signUpFlow = signUpFlow
        self.store = store
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("new_wallet", comment: "")
        contentView.continueButton.addTarget(self, action: #selector(onContinueHandler), for: .touchUpInside)
    }
    
    private func showSeed(_ seed: String?) {
        guard let seed = seed else { return }
        let name = self.name
        
        if let alert = presentedViewController {
            alert.dismiss(animated: true) { [weak self] in
                self?.signUpFlow?.change(route: .seed(Date(), name, seed))
            }
            return
        }
        
        signUpFlow?.change(route: .seed(Date(), name, seed))
    }

    @objc
    private func onContinueHandler() {
        let name = self.name
        let type = WalletType.monero
        let title = NSLocalizedString("creating_wallet", comment: "")
            + " "
            + name
        showSpinner(withTitle: title) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.create(
                    withName: name,
                    andType: type,
                    handler: { [weak self] seed in self?.showSeed(seed) }
                )
            )
        }
    }
}
