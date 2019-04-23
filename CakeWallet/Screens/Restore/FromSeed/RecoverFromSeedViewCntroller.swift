import UIKit
import CakeWalletLib
import CakeWalletCore

final class RecoverFromSeedViewCntroller: BaseViewController<RecoverFromSeedView> {
    let store: Store<ApplicationState>
    let type: WalletType
    weak var restoreWalletFlow: RestoreWalletFlow?
    
    init(store: Store<ApplicationState>, type: WalletType = .monero, restoreWalletFlow: RestoreWalletFlow) {
        self.store = store
        self.type = type
        self.restoreWalletFlow = restoreWalletFlow
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore_seed_card_title", comment: "")
        contentView.doneButton.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
        
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
        
        if let walletName = contentView.walletNameField.textField.text,
            let seed = contentView.seedField.textField.text {
            
            self.store.dispatch(
                WalletActions.restoreFromSeed(
                    withName: walletName,
                    andSeed: seed,
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
