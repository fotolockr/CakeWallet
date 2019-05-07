import UIKit
import CakeWalletLib
import CakeWalletCore

final class RecoverFromKeysViewController: BaseViewController<RecoverFromKeysView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(store: Store<ApplicationState>, restoreWalletFlow: RestoreWalletFlow, type: WalletType = .monero) {
        self.restoreWalletFlow = restoreWalletFlow
        self.store = store
        self.type = type
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore_keys_card_title", comment: "")
        contentView.doneButton.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        super.configureBinds()
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
        contentView.doneButton.showLoading()
        
        if let walletName = contentView.walletNameField.text,
            let address = contentView.addressTextView.text,
            let viewKey = contentView.viewKeyField.text,
            let spendKey = contentView.spendKeyField.text {
            
            self.store.dispatch(
                WalletActions.restoreFromKeys(
                    withName: walletName,
                    andAddress: address,
                    viewKey: viewKey,
                    spendKey: spendKey,
                    restoreHeight: contentView.restoreFromHeightView.restoreHeight,
                    type: type,
                    handler: { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.done()
                        case let .failed(error):
                            self?.contentView.doneButton.hideLoading()
                            self?.showErrorAlert(error: error)
                        }
                    }
                )
            )
        }
    }
}
