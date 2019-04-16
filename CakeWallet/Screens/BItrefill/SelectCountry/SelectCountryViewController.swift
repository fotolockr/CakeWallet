import UIKit
import SwiftyJSON
import Alamofire


protocol BitrefillSelectCountryDelegate: class {
    func dataFromCountrySelect(categories: [BitrefillCategory], products: [BitrefillProduct])
}

final class BitrefillSelectCountryViewController: BlurredBaseViewController<BitrefillSelectCountryView>, UIPickerViewDelegate, UIPickerViewDataSource, BitrefillFetchCountryData {

    weak var bitrefillFlow: BitrefillFlow?
    weak var delegate: BitrefillSelectCountryDelegate?
    var selectedCountry: BitrefillCountry = .us

    init(bitrefillFlow: BitrefillFlow?) {
        self.bitrefillFlow = bitrefillFlow
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.pickerView.delegate = self
        contentView.pickerView.dataSource = self
        contentView.doneButton.addTarget(self, action: #selector(omSubmit), for: .touchUpInside)
    }
    
    @objc
    func omSubmit() {
        contentView.doneButton.showLoading()
        
        bitrefillFetchCountryData(viewController: self, forCountry: selectedCountry, handler: { [weak self] categories, products in
            self?.delegate?.dataFromCountrySelect(categories: categories, products: products)
            self?.contentView.doneButton.hideLoading()
            
            UserDefaults.standard.set(self?.selectedCountry.rawValue, forKey: Configurations.DefaultsKeys.bitrefillSelectedCountry)
            
            self?.dismiss(animated: true) { () -> Void in
                self?.onDismissHandler?()
            }
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BitrefillCountry.all.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return BitrefillCountry.all[row].fullCountryName()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = BitrefillCountry.all[row]
        contentView.countryTextField.textField.text = BitrefillCountry.all[row].fullCountryName()
    }
}

