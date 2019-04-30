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
        title = NSLocalizedString("address_book", comment: "")
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton

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
            let addButton = makeIconedNavigationButton(iconName: "add_icon_purple", target: self, action: #selector(addNewAddressItem))
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
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
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
        return AddressTableCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        if let isReadOnly = self.isReadOnly, isReadOnly {
            dismissAction()
            doneHandler?(contact.address)
        } else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
                UIPasteboard.general.string = contact.address
            }
            
            var actions = [cancelAction, copyAction]
            
            // fixme: hardcoded value .monero,
            // it must be depend on current wallet type or will be removed when send screen will support exchange
            if contact.type == .monero {
                let sendAction = UIAlertAction(title: "Send", style: .default) { [weak self] _ in
                    guard let store = self?.store else { return }
                    
                    let sendVC = SendViewController(store: store, address: contact.address)
                    let sendNavigation = UINavigationController(rootViewController: sendVC)
                    self?.present(sendNavigation, animated: true)
                }
                
                actions.append(sendAction)
            }
            
            showInfoAlert(
                title: contact.name,
                message: contact.address,
                actions: [cancelAction, copyAction]
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
                self?.showErrorAlert(error: error)
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
