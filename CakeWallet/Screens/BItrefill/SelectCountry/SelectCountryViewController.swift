import UIKit
import SwiftyJSON
import Alamofire


enum BitrefillCountry: String {
    case af, ax, al, dz, ad, ao, ai, aq, ar, am, aw, au, at, az, bs, bh, bd, bb, by, be, br, bg, ca, cn, dk,
    eu, fr, de, mx, ru, us
    
    static var all: [BitrefillCountry] {
        return [
            .af, .ax, .al, .dz, .ad, .ao, .ai, .aq, .ar, .am, .aw, .au, .at, .az, .bs, .bh, .bd, .bb, .by, .be, .br, .bg, .ca, .cn, .dk,
            .eu, .fr, .de, ru, .us
        ]
    }
    
    func fullCountryName() -> String {
        switch self {
        case .af: return "Afghanistan"
        case .ax: return "Aland Islands"
        case .al: return "Albania"
        case .dz: return "Algeria"
        case .ad: return "Andorra"
        case .ao: return "Angola"
        case .ai: return "Anguilla"
        case .aq: return "Antarctica"
        case .ar: return "Argentina"
        case .am: return "Armenia"
        case .aw: return "Aruba"
        case .au: return "Australia"
        case .at: return "Austria"
        case .az: return "Azerbaijan"
        case .bs: return "Bahams"
        case .bh: return "Bahrain"
        case .bd: return "Bangladesh"
        case .bb: return "Barbados"
        case .by: return "Belarus"
        case .be: return "Belgium"
        case .br: return "Brazil"
        case .bg: return "Bulgaria"
        case .ca: return "Canada"
        case .cn: return "China"
        case .dk: return "Denmark"
        case .eu: return "EU"
        case .fr: return "France"
        case .de: return "Germany"
        case .mx: return "Mexico"
        case .ru: return "Russia"
        case .us: return "USA"
        }
    }
}


protocol BitrefillFetchCountryData: class {
    func bitrefillFetchCountryData(forCountry: BitrefillCountry, handler: @escaping ([BitrefillCategory], [BitrefillProduct]) -> Void) -> Void
}

extension BitrefillFetchCountryData {
    func bitrefillFetchCountryData(forCountry: BitrefillCountry, handler: @escaping ([BitrefillCategory], [BitrefillProduct]) -> Void) -> Void {
        let url = URLComponents(string: "https://www.bitrefill.com/api/widget/country/\(forCountry.rawValue.uppercased())")!
        var sortedCategories = [BitrefillCategory]()
        var products = [BitrefillProduct]()
        
        Alamofire.request(url, method: .get).responseData(completionHandler: { response in
            guard let data = response.data else { return }
            let operatorsList = JSON(data)["operators"]
            var countrySpecificCategories = Set<BitrefillCategoryType>()
            
            for (_, subJson):(String, JSON) in operatorsList {
                if let categoryType = BitrefillCategoryType(rawValue: subJson["type"].stringValue) {
                    countrySpecificCategories.insert(categoryType)
                }
                
                let product = BitrefillProduct(json: subJson)
                products.append(product)
            }
            
            let categories = countrySpecificCategories.map({(categoryType: BitrefillCategoryType) -> BitrefillCategory in
                return BitrefillCategory(name: categoryType.categoryName, type: categoryType, icon: categoryType.categoryIcon)
            })
            
            sortedCategories = categories.sorted { $0.type.categoryOrder < $1.type.categoryOrder }
            
            handler(sortedCategories, products)
        })
    }
}


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
        
        bitrefillFetchCountryData(forCountry: selectedCountry, handler: { [weak self] categories, products in
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

