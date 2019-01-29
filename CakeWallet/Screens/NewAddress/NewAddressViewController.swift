import UIKit
import CakeWalletLib
import CakeWalletCore


final class NewAddressViewController: BaseViewController<NewAddressView>, UIPickerViewDataSource, UIPickerViewDelegate {
    override func viewDidLoad() {
        contentView.pickerView.delegate = self
        contentView.pickerView.dataSource = self
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("New Address", comment: "")
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
