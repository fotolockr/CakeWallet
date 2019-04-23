import UIKit
import CakeWalletLib

final class RescanViewController: BaseViewController<RescanView> {
    override func configureBinds() {
        title = NSLocalizedString("rescan", comment: "")
        contentView.rescanButton.addTarget(self, action: #selector(rescanAction), for: .touchUpInside)
    }
    
    @objc
    private func rescanAction() {
        let height = contentView.restoreFromHeightView.restoreHeight
        
        showSpinnerAlert(withTitle: NSLocalizedString("starting_rescan", comment: "")) { [weak self] alert in
            store.dispatch(
                WalletActions.rescan(fromHeight: height) {
                    alert.dismiss(animated: true) {
                        self?.navigationController?.popToRootViewController(animated: true)
                        self?.navigationController?.viewControllers.first?.dismiss(animated: true)
                    }
                }
            )
        }
    }
}
