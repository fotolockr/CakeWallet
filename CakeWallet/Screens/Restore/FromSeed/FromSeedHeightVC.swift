import UIKit
import CakeWalletLib
import CakeWalletCore

final class FromSeedHeightVC: BaseViewController<FromSeedHeightView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var restoreWalletFlow: RestoreWalletFlow?
    let wizzardStore: WizzardStore<WizzardRestoreFromSeedState>
    
    init(
        restoreWalletFlow: RestoreWalletFlow,
        store: Store<ApplicationState>,
        wizzardStore: WizzardStore<WizzardRestoreFromSeedState>,
        type: WalletType = .monero
        ) {
        self.restoreWalletFlow = restoreWalletFlow
        self.wizzardStore = wizzardStore
        self.type = type
        self.store = store
        super.init()
    }
    
    override func configureBinds() {
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
            wizzardStore.change(state: WizzardRestoreFromSeedState(
                name: state.name,
                seed: state.seed,
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
        let state = wizzardStore.state
        
        if let heightFieldText = contentView.restoreFromHeightView.restoreHeightTextField.text,
            let dateFieldText = contentView.restoreFromHeightView.dateTextField.text,
            let height = UInt64(heightFieldText) {
            wizzardStore.change(state: WizzardRestoreFromSeedState(
                name: state.name,
                seed: state.seed,
                height: height,
                date: dateFieldText
            ))
        }
        
        guard let restoreHeight = wizzardStore.state.height else {
            return
        }
        
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
        
        let name = state.name
        let seed = state.seed
        let type = self.type
        showSpinner(withTitle: NSLocalizedString("restoring_wallet", comment: "")) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.restoreFromSeed(
                    withName: name,
                    andSeed: seed,
                    restoreHeight: restoreHeight,
                    type: type,
                    handler: { [weak self] in
                        if let error = self?.store.state.error {
                            alert.dismiss(animated: true) {
                                self?.showInfo(title: nil, message: error.localizedDescription, actions: [CWAlertAction.cancelAction])
                            }
                            
                            return
                        }
                        
                        self?.done()
                    }
                )
            )
        }
    }
    
    private func focusRestoreHeightField() {
        contentView.restoreFromHeightView.restoreHeightTextField.becomeFirstResponder()
    }
}
