import UIKit
import CakeWalletLib
import CakeWalletCore

final class FromKeysHeightVC: BaseViewController<FromKeysHeightView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let store: Store<ApplicationState>
    let type: WalletType
    let wizzardStore: WizzardStore<WizzardRestoreFromKeysState>
    
    init(restoreWalletFlow: RestoreWalletFlow, wizzardStore: WizzardStore<WizzardRestoreFromKeysState>, store: Store<ApplicationState>, type: WalletType = .monero) {
        self.restoreWalletFlow = restoreWalletFlow
        self.wizzardStore = wizzardStore
        self.store = store
        self.type = type
        super.init()
    }
    
    override func configureBinds() {
        title =  NSLocalizedString("restore_height", comment: "")
        if let height = wizzardStore.state.height {
            contentView.restoreFromHeightView.restoreHeightTextField.text = String(height)
        }
        
        contentView.restoreFromHeightView.dateTextField.text = String(wizzardStore.state.date)
        
        contentView.doneButton.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
        super.configureBinds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let state = wizzardStore.state
        
        if let heightFieldText = contentView.restoreFromHeightView.restoreHeightTextField.text,
           let dateFieldText = contentView.restoreFromHeightView.dateTextField.text,
           let height = UInt64(heightFieldText) {
            wizzardStore.change(state: WizzardRestoreFromKeysState(
                name: state.name,
                address: state.address,
                viewKey: state.viewKey,
                spendKey: state.spendKey,
                height: height,
                date: dateFieldText
            ))
        }
    }
    
    private func done() {
        if let alert = presentedViewController {
            alert.dismiss(animated: true) { [weak self] in
                self?.restoreWalletFlow?.doneHandler?()
            }
            return
        }
        
        restoreWalletFlow?.doneHandler?()
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
        let state = wizzardStore.state
        let type = self.type
        
        showSpinner(withTitle:  NSLocalizedString("restoring_wallet", comment: "")) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.restoreFromKeys(
                    withName: state.name,
                    andAddress: state.address,
                    viewKey: state.viewKey,
                    spendKey: state.spendKey,
                    restoreHeight: restoreHeight,
                    type: type,
                    handler: { [weak self] in self?.done() }
                )
            )
        }
    }
    
    
    private func focusRestoreHeightField() {
        contentView.restoreFromHeightView.restoreHeightTextField.becomeFirstResponder()
    }
}
