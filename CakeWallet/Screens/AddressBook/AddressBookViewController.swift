import UIKit
import CakeWalletLib
import FlexLayout
import SwiftyJSON

protocol JSONExportable {
    var primaryKey: String { get }
    func toJSON() -> JSON
}

protocol JSONImportable {
    init?(from json: JSON)
}

protocol JSONConvertable: JSONExportable, JSONImportable {}

extension Contact: JSONConvertable {
    init?(from json: JSON) {
        guard
            let typeRaw = json["type"].string,
            let type = CryptoCurrency(from: typeRaw) else {
                return nil
        }
        
        self.uuid = json["uuid"].stringValue
        self.type = type
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
    }
    
    var primaryKey: String {
        return "uuid"
    }
    
    func toJSON() -> JSON {
        return JSON(["name": name, "type": type.formatted(), "address": address])
    }
}

class AddressBook {
    static let shared: AddressBook = AddressBook()
    
    private static let name = "address_book.json"
    
    private static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    }
    
    private static func load() -> JSON {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) else {
                return JSON()
        }
        
        return json
    }
    
    private var json: JSON
    
    private init() {
        json = AddressBook.load()
    }
    
    func all() -> [Contact] {
        return json.array?.map({ json -> Contact? in
            return Contact(from: json)
        }).compactMap({ $0 }) ?? []
    }
    
    func addOrUpdate(contact: Contact) throws {
        let isExist = json.arrayValue
            .filter({ $0[contact.primaryKey].stringValue == contact.uuid })
            .first != nil
        let updatedJson: JSON
        
        if isExist {
            updatedJson = JSON(json.arrayValue.map({ json -> JSON in
                let currentUuid = json[contact.primaryKey].stringValue
                
                if currentUuid == contact.uuid {
                    return contact.toJSON()
                }
                
                return json
            }))
        } else {
            let array = json.arrayValue + [contact.toJSON()]
            updatedJson = JSON(array)
        }
        
        try save(json: updatedJson)
        json = updatedJson
        print("updatedJson \(updatedJson)")
        print("json \(json)")
    }
    
    private func save(json: JSON) throws {
        try json.rawData().write(to: AddressBook.url)
    }
}



final class AddressTableCell: FlexCell {
    let nameLabel = UILabel(fontSize: 15)
    let typeLabel = UILabel(fontSize: 12)
    let leftViewWrapper = UIView()
    let typeViewWrapper = UIView()
    let typeView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        backgroundColor = .clear
        contentView.layer.applySketchShadow(color: .wildDarkBlue, alpha: 0.25, x: 10, y: 3, blur: 13, spread: 2)
        selectionStyle = .none

        typeLabel.textColor = .white
        typeView.layer.borderWidth = 1
        typeView.layer.cornerRadius = 8
        typeView.layer.masksToBounds = true
    }
    
    override func configureConstraints() {
        contentView.flex
            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
            .padding(5, 10, 5, 10)
            .height(50)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .define { flex in
                flex.addItem(leftViewWrapper).define({ wrapperFlex in
                    wrapperFlex
                        .direction(.row)
                        .justifyContent(.spaceBetween)
                        .alignItems(.center)
                        .addItem(typeViewWrapper)
                            .width(90)
                            .alignItems(.center)
                            .addItem(typeView)
                                .marginRight(14)
                                .padding(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
                                .addItem(typeLabel)
                    wrapperFlex.addItem(nameLabel)
                })
        }
    }
    
    func configure(name: String, type: String, color: UIColor) {
        nameLabel.text = name
        typeLabel.text = type
        typeLabel.textColor = color
        typeView.layer.borderColor = color.cgColor
        nameLabel.flex.markDirty()
        typeLabel.flex.markDirty()
        contentView.flex.layout()
    }
}

struct Contact {
    let uuid: String
    let type: CryptoCurrency
    let name: String
    let address: String
    
    init(uuid: String = UUID().uuidString, type: CryptoCurrency, name: String, address: String) {
        self.uuid = uuid
        self.type = type
        self.name = name
        self.address = address
    }
}

extension Contact: CellItem {
    private func color(for currency: CryptoCurrency) -> UIColor {
        switch currency {
        case .bitcoin:
            return UIColor(hex: 0xFF9900)
        case .bitcoinCash:
            return UIColor(hex: 0xee8c28)
        case .monero:
            return UIColor(hex: 0xff7519)
        case .ethereum:
            return UIColor(hex: 0x303030)
        case .liteCoin:
            return UIColor(hex: 0x88caf5)
        case .dash:
            return UIColor(hex: 0x008de4)
        }
    }
    
    func setup(cell: AddressTableCell) {
        cell.configure(name: name, type: type.formatted(), color: color(for: type))
    }
}

final class AddressBookViewController: BaseViewController<AddressBookView>, UITableViewDelegate, UITableViewDataSource {
    let addressBoook: AddressBook
    
    private var contacts: [Contact]
    
    init(addressBoook: AddressBook) {
        self.addressBoook = addressBoook
        contacts = addressBoook.all()
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Address Book"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewAddressItem))
        navigationItem.rightBarButtonItems = [addButton]
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [Contact.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContacts()
    }
    
    private func refreshContacts() {
        contacts = addressBoook.all()
        contentView.table.reloadData()
    }
    
    @objc
    private func addNewAddressItem(){
        navigationController?.pushViewController(NewAddressViewController(addressBoook: AddressBook.shared), animated: true)
    }
    
    @objc
    private func copyAction() {
        showInfo(title: NSLocalizedString("copied", comment: ""), withDuration: 1, actions: [])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        showInfo(
            title: contact.name,
            message: "hash",
            actions: [
                CWAlertAction(title: "Send", handler: { action in
                    action.alertView?.dismiss(animated: true)
                }),
                CWAlertAction(title: "Copy", handler: { action in
                    UIPasteboard.general.string = "hash"
                    action.alertView?.dismiss(animated: true)
                })
            ])
    }
}
