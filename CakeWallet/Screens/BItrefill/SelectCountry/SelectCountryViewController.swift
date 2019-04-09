import UIKit
import SwiftyJSON
import Alamofire

protocol BitrefillSelectCountryDelegate: class {
    func onCountry(selected country: String)
}

final class BitrefillSelectCountryViewController: BlurredBaseViewController<BitrefillSelectCountryView>, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickerOptions = ["Ukraine", "United states", "United kingdom", "Poland", "Germany", "Spain", "Portugal"]
    weak var bitrefillFlow: BitrefillFlow?
    weak var delegate: BitrefillSelectCountryDelegate?

    
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
//        contentView.doneButton.showLoading()
        
        delegate?.onCountry(selected: "Awesome country")
        
//        let url = URLComponents(string: "https://www.bitrefill.com/api/widget/country/US")!
//        var products = [BitrefillProduct]()
//
//        Alamofire.request(url, method: .get).responseData(completionHandler: { [weak self] response in
//            guard let data = response.data else { return }
//            let operatorsList = JSON(data)["operators"]
//            var countrySpecificCategories = Set<BitrefillCategoryType>()
//
//            for (_, subJson):(String, JSON) in operatorsList {
//                if let categoryType = BitrefillCategoryType(rawValue: subJson["type"].stringValue) {
//                    countrySpecificCategories.insert(categoryType)
//                }
//
//                do {
//                    let product = try BitrefillProduct(json: subJson)
//                    products.append(product)
//                } catch {
//                    print("Couldn't fetch bitrefill products")
//                }
//            }
//
//            let categories = countrySpecificCategories.map({(categoryType: BitrefillCategoryType) -> BitrefillCategory in
//                return BitrefillCategory(name: categoryType.categoryName, type: categoryType, icon: categoryType.categoryIcon)
//            })
//
//            let sortedCategories = categories.sorted { $0.type.categoryOrder < $1.type.categoryOrder }
//
////            self?.contentView.doneButton.hideLoading()
//
//            self?.delegate?.onCountry(selected: "Awesome country")
//
//
////            self?.dismissAction()
//        })
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
        contentView.countryTextField.textField.text = pickerOptions[row]
    }
}
