import UIKit

final class RestoreFromCloudVC: BaseViewController<RestoreFromCloudView>, UIDocumentPickerDelegate {
    let backup: BackupService
    let storage: CloudStorage
    var doneHandler: (() -> Void)?
    
    init(backup: BackupService, storage: CloudStorage) {
        self.backup = backup
        self.storage = storage
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Import backup"
        contentView.importFromCloudButton.addTarget(self, action: #selector(openDocumentsPickerFromCloud), for: .touchUpInside)
    }
    
    // MARK: UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let alert = UIAlertController(title: "Restore from backup", message: "Enter password", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak self] (_) in
            guard let password = alert?.textFields?.first?.text else {
                return
            }
            
            //            alert?.dismiss(animated: true) { [password, weak self] in
            self?.importFile(from: url, withPassword: password)
            //            }
        }))
        
        present(alert, animated: true)
    }
    
    private func importFile(from url: URL, withPassword password: String) {
        showSpinner(withTitle: "Restoring from backup") { [weak self] alert in
            do {
                try self?.backup.import(from: url, withPassword: password)
                let handler = LoadCurrentWalletHandler()
                handler.handle(action: WalletActions.loadCurrentWallet, store: store, handler: { action in
                    DispatchQueue.main.async {
                        guard let action = action else {
                            return
                        }
                        
                        store._defaultDispatch(action)
                        
                        if
                            let action = action as? ApplicationState.Action,
                            case let .changedError(_error) = action,
                            let error = _error {
                            alert.dismiss(animated: true) {
                                self?.showError(error: error)
                            }
                            return
                        }
                        
                        if let action = action as? WalletState.Action, case .loaded(_) = action {
                            alert.dismiss(animated: true) {
                                self?.doneHandler?()
                            }
                        }
                    }
                })
            } catch {
                alert.dismiss(animated: true) {
                    self?.showError(error: error)
                }
            }
        }
    }
    
    @objc
    private func openDocumentsPickerFromCloud() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["iCloud.com.fotolockr.cakewallet", "public.item", "public.content", "public.text", "public.data", "public.zip-archive"], in: .import)
        importMenu.delegate = self
        self.present(importMenu, animated: true, completion: nil)
    }
}
