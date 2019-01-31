import UIKit
import CakeWalletLib
    

final class FromKeysWalletNameVC: BaseViewController<FromKeysWalletNameView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let wizzardStore: WizzardStore<WizzardRestoreFromKeysState>
    
    init(restoreWalletFlow: RestoreWalletFlow, wizzardStore: WizzardStore<WizzardRestoreFromKeysState>) {
        self.restoreWalletFlow = restoreWalletFlow
        self.wizzardStore = wizzardStore
        super.init()
    }
    
    override func configureBinds() {
        title = "Wallet name"
        contentView.nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        contentView.walletNameTextField.text = wizzardStore.state.name
        super.configureBinds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let state = wizzardStore.state
        
        if let fieldText = contentView.walletNameTextField.text {
            wizzardStore.change(state: WizzardRestoreFromKeysState(
                name: fieldText,
                address: state.address,
                viewKey: state.viewKey,
                spendKey: state.spendKey,
                height: state.height,
                date: state.date
            ))
        }
    }
    
    @objc
    private func nextStep() {
        if let fieldText = contentView.walletNameTextField.text, fieldText.count > 0 {
            restoreWalletFlow?.change(route: .fromKeysKeys)
        }
    }
}
