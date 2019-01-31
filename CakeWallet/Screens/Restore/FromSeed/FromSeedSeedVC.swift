import UIKit
import CakeWalletLib

final class FromSeedSeedVC: BaseViewController<FromSeedSeedView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let wizzardStore: WizzardStore<WizzardRestoreFromSeedState>
    
    init(restoreWalletFlow: RestoreWalletFlow, wizzardStore: WizzardStore<WizzardRestoreFromSeedState>) {
        self.restoreWalletFlow = restoreWalletFlow
        self.wizzardStore = wizzardStore
        super.init()
    }
    
    override func configureBinds() {
        title = "Seed"
        contentView.nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        contentView.seedTextField.text = wizzardStore.state.seed
        super.configureBinds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let state = wizzardStore.state
        
        if let fieldText = contentView.seedTextField.text {
            wizzardStore.change(state: WizzardRestoreFromSeedState(
                name: state.name,
                seed: fieldText,
                height: state.height,
                date: state.date
            ))
        }
    }
    
    @objc
    private func nextStep() {
        if let fieldText = contentView.seedTextField.text, fieldText.count > 0 {
            restoreWalletFlow?.change(route: .fromSeedHeight)
        }
    }
}
