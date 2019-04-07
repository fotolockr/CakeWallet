import UIKit
import FlexLayout
import SwiftyJSON
import Alamofire


final class BitrefillBaseViewController: BaseViewController<BitrefillBaseView>, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var bitrefillProducts = [BitrefillProduct]()
    var bitrefillCategories = [BitrefillCategory]()
    
    init(bitrefillFlow: BitrefillFlow?) {
        self.bitrefillFlow = bitrefillFlow
        
        super.init()
        
        tabBarItem = UITabBarItem(
            title: "Bitrefill",
            image: UIImage(named: "bitrefill_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bitrefill_selected_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func viewDidLoad() {
        var countryWasChosen = false
        
        if !countryWasChosen {
            bitrefillFlow?.change(route: .selectCountry)
            return
        }
        

        fetchBitrefillData()
    }
    

    
    private func fetchBitrefillData(forCountry country: String = "US") {
        let url = URLComponents(string: "https://www.bitrefill.com/api/widget/country/\(country)")!
        
        Alamofire.request(url, method: .get).responseData(completionHandler: { [weak self] response in
            guard let data = response.data else { return }
            let operatorsList = JSON(data)["operators"]
            var countrySpecificCategories = Set<BitrefillCategoryType>()
            
            for (_, subJson):(String, JSON) in operatorsList {
                if let categoryType = BitrefillCategoryType(rawValue: subJson["type"].stringValue) {
                    countrySpecificCategories.insert(categoryType)
                }
                
                do {
                    let product = try BitrefillProduct(json: subJson)
                    self?.bitrefillProducts.append(product)
                } catch {
                    print("Couldn't fetch bitrefill products")
                }
            }
            
            let categories = countrySpecificCategories.map({(categoryType: BitrefillCategoryType) -> BitrefillCategory in
                return BitrefillCategory(name: categoryType.categoryName, type: categoryType, icon: categoryType.categoryIcon)
            })
            
            self?.bitrefillCategories = categories.sorted { $0.type.categoryOrder < $1.type.categoryOrder }
            
            self?.contentView.table.reloadData()
            self?.contentView.loaderHolder.isHidden = true
        })
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
        
        let ProductListVC = BitrefillProductListViewController(bitrefillFlow: bitrefillFlow, products: sortedCategoryProducts)
        
        if categoryProducts.count > 0 {
            bitrefillFlow?.change(viewController: ProductListVC)
        }
    }
}
