import UIKit
import CakeWalletLib

final class RestoreVC: BaseViewController<RecoverView> {
    weak var restoreWalletFlow: RestoreWalletFlow?
    let type: WalletType
    
    init(restoreWalletFlow: RestoreWalletFlow, type: WalletType = .monero) {
        self.restoreWalletFlow = restoreWalletFlow
        self.type = type
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("restore", comment: "")
        contentView.titleLabel.text = NSLocalizedString("restore_your_wallet", comment: "")
        contentView.descriptionLabel.text = NSLocalizedString("restore_selection_text", comment: "")
        contentView.fromKeysButton.addTarget(self, action: #selector(fromKeys), for: .touchUpInside)
        contentView.fromSeedButton.addTarget(self, action: #selector(fromSeed), for: .touchUpInside)
        switch type {
        case .monero:
            contentView.cryptoIconImageView.image = UIImage(named: "monero_logo")
        case .bitcoin:
            break
        }
    }
    
    @objc
    private func fromSeed() {
        restoreWalletFlow?.change(route: .fromSeedWalletName)
    }
    
    @objc
    private func fromKeys() {
        restoreWalletFlow?.change(route: .fromKeysWalletName)
    }
}
