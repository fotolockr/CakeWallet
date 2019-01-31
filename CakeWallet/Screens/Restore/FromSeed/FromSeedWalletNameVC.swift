import UIKit
import CakeWalletLib

final class FromSeedWalletNameVC: BaseViewController<FromSeedWalletNameView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let wizzardStore: WizzardStore<WizzardRestoreFromSeedState>
    
    init(restoreWalletFlow: RestoreWalletFlow, wizzardStore: WizzardStore<WizzardRestoreFromSeedState>) {
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
            wizzardStore.change(state: WizzardRestoreFromSeedState(
                name: fieldText,
                seed: state.seed,
                height: state.height,
                date: state.date
            ))
        }
    }
    
    @objc
    private func nextStep() {
        if let fieldText = contentView.walletNameTextField.text, fieldText.count > 0 {
            restoreWalletFlow?.change(route: .fromSeedSeed)
        }
    }
}
