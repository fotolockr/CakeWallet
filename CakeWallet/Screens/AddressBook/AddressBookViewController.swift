import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout
import SwiftyJSON

final class AddressBookViewController: BaseViewController<AddressBookView>, UITableViewDelegate, UITableViewDataSource {
    let addressBook: AddressBook
    let store: Store<ApplicationState>
    let isReadOnly: Bool?
    var doneHandler: ((String) -> Void)?
    
    private var contacts: [Contact]
    
    init(addressBook: AddressBook, store: Store<ApplicationState>, isReadOnly: Bool?) {
        self.addressBook = addressBook
        self.store = store
        self.isReadOnly = isReadOnly
        contacts = addressBook.all()
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Address Book"

        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [Contact.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContacts()
        
        let isModal = self.isModal
        renderActionButtons(for: isModal)
    }
    
    private func renderActionButtons(for isModal: Bool) {
        if !isModal {
            let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewAddressItem))
            navigationItem.rightBarButtonItems = [addButton]
        } else {
            let doneButton = StandartButton.init(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 12, height: 12)))
            doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
            doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        }
    }
    
    private func refreshContacts() {
        contacts = addressBook.all()
        contentView.table.reloadData()
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    @objc
    private func addNewAddressItem(){
        navigationController?.pushViewController(NewAddressViewController(addressBoook: AddressBook.shared), animated: true)
    }
    
    @objc
    private func copyAction() {
        showInfo(title: NSLocalizedString("copied", comment: ""), withDuration: 1, actions: [CWAlertAction.okAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = contacts.count == 0 ? createNoDataLabel(with: tableView.bounds.size) : nil
        tableView.separatorStyle = .none
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        return tableView.dequeueReusableCell(withItem: contact, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        if let isReadOnly = self.isReadOnly, isReadOnly {
            dismissAction()
            doneHandler?(contact.address)
        } else {
            var actions = [
                .cancelAction,
                CWAlertAction(title: "Copy", handler: { action in
                    UIPasteboard.general.string = contact.address
                    action.alertView?.dismiss(animated: true)
                })
            ]
            
            // fixme: hardcoded value .monero,
            // it must be depend on current wallet type or will be removed when send screen will support exchange
            if contact.type == .monero {
                actions.append(CWAlertAction(title: "Send", handler: { action in
                    action.alertView?.dismiss(animated: true) {
                        let sendVC = SendViewController(store: self.store, address: contact.address)
                        let sendNavigation = UINavigationController(rootViewController: sendVC)
                        self.present(sendNavigation, animated: true)
                    }
                }))
            }
            
            showInfo(
                title: contact.name,
                message: contact.address,
                actions: actions
            )
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler ) in
            guard let contact = self?.contacts[indexPath.row] else {
                return
            }
            let newContactVC = NewAddressViewController(
                addressBoook: AddressBook.shared,
                contact: contact
            )
            self?.navigationController?.pushViewController(newContactVC, animated: true)
        }
        
        editAction.image = UIImage(named: "edit_icon")
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler ) in
            guard let uuid = self?.contacts[indexPath.row].uuid else {
                return
            }
            
            do {
                try self?.addressBook.delete(for: uuid)
                self?.contacts = self?.addressBook.all() ?? []
                self?.contentView.table.reloadData()
            } catch {
                self?.showError(error: error)
            }
        }
        
        deleteAction.image = UIImage(named: "trash_icon")
        
        let confrigation = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return confrigation
    }
    
    private func createNoDataLabel(with size: CGSize) -> UIView {
        let noDataLabel: UILabel = UILabel(frame: CGRect(origin: .zero, size: size))
        noDataLabel.text = "No contacts yet"
        noDataLabel.textColor = UIColor(hex: 0x9bacc5)
        noDataLabel.textAlignment = .center
        
        return noDataLabel
    }
}
