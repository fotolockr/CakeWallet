import UIKit
import CakeWalletLib

final class FromKeysKeysVC: BaseViewController<FromKeysKeysView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let wizzardStore: WizzardStore<WizzardRestoreFromKeysState>
    
    init(restoreWalletFlow: RestoreWalletFlow, wizzardStore: WizzardStore<WizzardRestoreFromKeysState>) {
        self.restoreWalletFlow = restoreWalletFlow
        self.wizzardStore = wizzardStore
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("address", comment: "")
        contentView.nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        contentView.addressView.textView.text = wizzardStore.state.address
        contentView.viewKeyTextField.text = wizzardStore.state.viewKey
        contentView.spendKeyTextField.text = wizzardStore.state.spendKey
        super.configureBinds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let state = wizzardStore.state
        
        if let addressText = contentView.addressView.textView.text,
           let viewKeyText = contentView.viewKeyTextField.text,
           let spendKeyText = contentView.spendKeyTextField.text {
            wizzardStore.change(state: WizzardRestoreFromKeysState(
                name: state.name,
                address: addressText,
                viewKey: viewKeyText,
                spendKey: spendKeyText,
                height: state.height,
                date: state.date
            ))
        }
    }
    
    @objc
    private func nextStep() {
        if let addressText = contentView.addressView.textView.text,
            let viewKeyText = contentView.viewKeyTextField.text,
            let spendKeyText = contentView.spendKeyTextField.text,
            addressText.count > 0,
            viewKeyText.count > 0,
            spendKeyText.count > 0 {
                restoreWalletFlow?.change(route: .fromKeysHeight)
        }
    }
}
