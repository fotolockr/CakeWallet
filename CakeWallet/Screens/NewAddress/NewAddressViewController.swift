import UIKit
import CakeWalletLib
import CakeWalletCore

final class NewAddressViewController: BaseViewController<NewAddressView>, UIPickerViewDataSource, UIPickerViewDelegate {
    let addressBoook: AddressBook
    
    init(addressBoook: AddressBook) {
        self.addressBoook = addressBoook
        super.init()
    }
    
    override func viewDidLoad() {
        contentView.pickerView.delegate = self
        contentView.pickerView.dataSource = self
        
        contentView.pickerView.selectRow(0, inComponent: 0, animated: true)
        contentView.pickerTextField.text = CryptoCurrency.all[0].formatted()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("New Address", comment: "")
        contentView.resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        contentView.saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    @objc
    func resetAction() {
        contentView.contactNameTextField.text = ""
        contentView.pickerTextField.text = ""
        contentView.addressView.textView.text = ""
    }
    
    @objc
    func saveAction() {
        if let name = contentView.contactNameTextField.text,
            let address = contentView.addressView.textView.text,
            let typeText = contentView.pickerTextField.text,
            name.count > 0,
            address.count > 0,
            typeText.count > 0,
            let type = CryptoCurrency(from: typeText) {
            let newContact = Contact(type: type, name: name, address: address)
            
            do {
                try addressBoook.addOrUpdate(contact: newContact)
                navigationController?.popViewController(animated: true)
            } catch {
                showInfo(title: "Error has occurred, please try again", actions: [CWAlertAction.okAction])
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
        contentView.pickerTextField.text = CryptoCurrency.all[row].formatted()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CryptoCurrency.all[row].formatted()
    }
}
