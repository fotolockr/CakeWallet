import Foundation
import UIKit
import CakeWalletLib
import CakeWalletCore

final class SeedViewController: BaseViewController<SeedView>, StoreSubscriber {
    private(set) var date: Date?
    private(set) var seed: String
    private var doneFlag: Bool
    var doneHandler: (() -> Void)?
    private var store: Store<ApplicationState>?
    private var walletName: String {
        didSet {
            contentView.titleLabel.text = walletName
        }
    }
    
    init(store: Store<ApplicationState>?, doneFlag: Bool = false) {
        self.store = store
        self.date = Date()
        self.seed = ""
        self.doneFlag = doneFlag
        self.walletName = store?.state.walletState.name ?? ""
        super.init()
    }
    
    init(walletName: String, date: Date, seed: String, doneFlag: Bool = false) {
        self.date = date
        self.seed = seed
        self.doneFlag = doneFlag
        self.walletName = walletName
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("seed", comment: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"

        contentView.titleLabel.text = walletName
        contentView.seedLabel.text = seed
        contentView.desciptionLabel.text = NSLocalizedString("seed_disclaimer", comment: "")
        contentView.saveButton.addTarget(self, action: #selector(showSaveMenu), for: .touchUpInside)
        contentView.copyButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        contentView.rootFlexContainer.flex.layout()

        if doneFlag {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
            navigationItem.rightBarButtonItems = [doneButton]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let store = store {
            store.subscribe(self)
            store.dispatch(
                WalletActions.fetchSeed
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store?.unsubscribe(self)
    }
    
    func onStateChange(_ state: WalletState) {
        updateSeed(state.seed)
        walletName = state.name
    }
    
    @objc
    private func showSaveMenu() {
        let activityViewController = UIActivityViewController(
            activityItems: [seed],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.message, UIActivityType.mail,
            UIActivityType.print, UIActivityType.copyToPasteboard]
        present(activityViewController, animated: true)
    }
    
    @objc
    private func doneAction() {
        doneHandler?()
    }
    
    @objc
    private func copyAction() {
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
        UIPasteboard.general.string = seed
    }
    
    private func updateSeed(_ seed: String) {
        self.seed = seed
        contentView.seedLabel.text = seed
        contentView.seedLabel.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
}
