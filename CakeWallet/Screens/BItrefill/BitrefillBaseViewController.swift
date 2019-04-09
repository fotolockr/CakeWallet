import UIKit
import FlexLayout
import SwiftyJSON
import Alamofire


final class BitrefillBaseViewController: BaseViewController<BitrefillBaseView>, BitrefillFetchCountryData, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var bitrefillCategories = [BitrefillCategory]()
    var bitrefillProducts = [BitrefillProduct]()
    
    init(bitrefillFlow: BitrefillFlow?, categories: [BitrefillCategory], products: [BitrefillProduct]) {
        self.bitrefillFlow = bitrefillFlow
        self.bitrefillProducts = products
        self.bitrefillCategories = categories
        
        super.init()
        
        tabBarItem = UITabBarItem(
            title: "Bitrefill",
            image: UIImage(named: "bitrefill_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bitrefill_selected_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func viewDidLoad() {
        guard let selectedCountry = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.bitrefillSelectedCountry) else {
            bitrefillFlow?.change(route: .selectCountry)
            return
        }
        
        if let country = BitrefillCountry(rawValue: selectedCountry) {
            bitrefillFetchCountryData(forCountry: country, handler: { [weak self] categories, products in
                self?.bitrefillCategories = categories
                self?.bitrefillProducts = products
                
                self?.contentView.table.reloadData()
                self?.contentView.loaderHolder.isHidden = true
            })
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Category"
        tabBarItem.title = "Bitrefill" // Fixme: Hardcoded and duplicated value.
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [BitrefillCategory.self])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bitrefillCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = bitrefillCategories[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategoryType = bitrefillCategories[indexPath.row].type
        let products = self.bitrefillProducts
        let categoryProducts = products.filter { $0.type == selectedCategoryType.rawValue }
        let sortedCategoryProducts = categoryProducts.sorted{ $0.name < $1.name }
        
        if sortedCategoryProducts.count > 0 {
            bitrefillFlow?.change(route: .productsList(categoryProducts))
        }
    }
}

extension BitrefillBaseViewController: BitrefillSelectCountryDelegate {
    func dataFromCountrySelect(categories: [BitrefillCategory], products: [BitrefillProduct]) {
        bitrefillCategories = categories
        bitrefillProducts = products
        
        contentView.loaderHolder.isHidden = true
        contentView.table.reloadData()
    }
}
