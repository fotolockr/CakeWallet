import UIKit
import CakeWalletLib
import CakeWalletCore

final class NewAddressViewController: BaseViewController<NewAddressView>, UIPickerViewDataSource, UIPickerViewDelegate, QRUriUpdateResponsible {
    let addressBoook: AddressBook
    let contact: Contact?
    
    init(addressBoook: AddressBook, contact: Contact? = nil) {
        self.addressBoook = addressBoook
        self.contact = contact
        super.init()
    }
    
    override func viewDidLoad() {
        contentView.pickerView.delegate = self
        contentView.pickerView.dataSource = self
        
        contentView.pickerView.selectRow(0, inComponent: 0, animated: true)
        contentView.pickerTextField.textField.text = CryptoCurrency.all[0].formatted()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let contact = self.contact {
            if let coinTypeIndex = CryptoCurrency.all.firstIndex(of: contact.type) {
                contentView.pickerTextField.textField.text = contact.type.formatted()
                contentView.pickerView.selectRow(coinTypeIndex, inComponent: 0, animated: true)
            }
            
            contentView.contactNameTextField.textField.text = contact.name
            contentView.addressView.textView.text = contact.address
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.addressView.presenter = self
        contentView.resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        contentView.saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        contentView.addressView.updateResponsible = self
    }
    
    @objc
    func resetAction() {
        contentView.contactNameTextField.textField.text = ""
        contentView.pickerTextField.textField.text = ""
        contentView.addressView.textView.text = ""
    }
    
    @objc
    func saveAction() {
        if let name = contentView.contactNameTextField.textField.text,
            let address = contentView.addressView.textView.text,
            let typeText = contentView.pickerTextField.textField.text,
            name.count > 0,
            address.count > 0,
            typeText.count > 0,
            let type = CryptoCurrency(from: typeText) {
            var uuid: String?
            
            if let contact = self.contact {
                uuid = contact.uuid
            }
           
            let contact = Contact(uuid: uuid, type: type, name: name, address: address)
            
            do {
                try addressBoook.addOrUpdate(contact: contact)
                navigationController?.popViewController(animated: true)
            } catch {
                showOKInfoAlert(title: "Error has occurred, please try again")
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CryptoCurrency.all.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        contentView.pickerTextField.textField.text = CryptoCurrency.all[row].formatted()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CryptoCurrency.all[row].formatted()
    }
    
    // QRUriUpdateResponsible
    
    func getCrypto(for adressView: AddressView) -> CryptoCurrency {
        guard
            let typeText = contentView.pickerTextField.textField.text,
            let type = CryptoCurrency(from: typeText) else {
            return .monero
        }
        
        return type
    }
    
    func updated(_ addressView: AddressView, withURI uri: QRUri) {
        contentView.addressView.textView.text = uri.address
    }
}
