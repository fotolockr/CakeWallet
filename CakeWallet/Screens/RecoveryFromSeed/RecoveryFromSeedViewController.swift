import UIKit
import CakeWalletLib
import CakeWalletCore

final class RestoreFromSeedViewController: BaseViewController<RestoreFromSeedView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var signUpFlow: SignUpFlow?
    private var name: String {
        return contentView.walletTextField.text ?? ""
    }
    
    init(signUpFlow: SignUpFlow, store: Store<ApplicationState>, type: WalletType = .monero) {
        self.signUpFlow = signUpFlow
        self.store = store
        self.type = type
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore_wallet", comment: "")
        contentView.recoverButton.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
    }
    
    private func done() {
        if let alert = presentedViewController {
            alert.dismiss(animated: true) { [weak self] in
                self?.signUpFlow?.doneHandler?()
            }
            return
        }
        
        signUpFlow?.doneHandler?()
    }
    
    @objc
    private func recoverAction() {
        let restoreHeight = contentView.restoreFromHeightView.restoreHeight
        
        if restoreHeight == 0 {
            let continueRestoreAction = CWAlertAction(title: NSLocalizedString("continue_restore", comment: "")) { action in
                action.alertView?.dismiss(animated: true) {
                    self.recover(from: restoreHeight)
                }
            }
            let setRestoreHeightAction = CWAlertAction(title: NSLocalizedString("set_restore_height", comment: "")) { action in
                action.alertView?.dismiss(animated: true) {
                    self.focusRestoreHeightField()
                }
            }
            showInfo(title: NSLocalizedString("enter_height_while_restore_alert", comment: ""), actions: [continueRestoreAction, setRestoreHeightAction])
        } else {
            recover(from: restoreHeight)
        }
    }
    
    private func recover(from restoreHeight: UInt64) {
        let name = self.name
        let seed = contentView.seedTextField.text ?? ""
        let type = self.type
        showSpinner(withTitle: NSLocalizedString("restoring_wallet", comment: "")) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.restoreFromSeed(
                    withName: name,
                    andSeed: seed,
                    restoreHeight: restoreHeight,
                    type: type,
                    handler: { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.done()
                        case let .failed(error):
                            alert.dismiss(animated: true) {
                                self?.showInfo(title: nil, message: error.localizedDescription, actions: [CWAlertAction.cancelAction])
                            }
                        }
                    }
                )
            )
        }
    }
    
    private func focusRestoreHeightField() {
        contentView.restoreFromHeightView.restoreHeightTextField.becomeFirstResponder()
    }
}
