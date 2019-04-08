import UIKit

final class BitrefillSelectCountryViewController: BlurredBaseViewController<BitrefillSelectCountryView>, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickerOptions = ["Ukraine", "United states", "United kingdom", "Poland", "Germany", "Spain", "Portugal"]
    
    override init() {
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.pickerView.delegate = self
        contentView.pickerView.dataSource = self
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        contentView.textFieldView.textField.text = pickerOptions[row]
    }
}
