import UIKit
import CakeWalletLib
import CakeWalletCore

final class RestoreFromKeysViewController: BaseViewController<RestoreFromKeysView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var signUpFlow: SignUpFlow?
    
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
        let name = contentView.walletNameTextField.text ?? ""
        let address = contentView.addressView.textView.text ?? ""
        let viewKey = contentView.viewKeyTextField.text ?? ""
        let spendKey = contentView.spendKeyTextField.text  ?? ""
        let type = self.type
        showSpinner(withTitle:  NSLocalizedString("restoring_wallet", comment: "")) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.restoreFromKeys(
                    withName: name,
                    andAddress: address,
                    viewKey: viewKey,
                    spendKey: spendKey,
                    restoreHeight: restoreHeight,
                    type: type,
                    handler: { [weak self] _ in self?.done() }
                )
            )
        }
    }
    
    private func focusRestoreHeightField() {
        contentView.restoreFromHeightView.restoreHeightTextField.becomeFirstResponder()
    }
}
