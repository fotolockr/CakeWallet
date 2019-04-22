import UIKit
import SwiftyJSON
import Alamofire


protocol BitrefillFetchCountryData: class {
    func bitrefillFetchCountryData(
        viewController: UIViewController,
        forCountry: BitrefillCountry,
        handler: @escaping ([BitrefillCategory], [BitrefillProduct]) -> Void
    ) -> Void
}

extension BitrefillFetchCountryData {
    func bitrefillFetchCountryData(viewController: UIViewController, forCountry: BitrefillCountry, handler: @escaping ([BitrefillCategory], [BitrefillProduct]) -> Void) -> Void {
        let url = URLComponents(string: "https://www.bitrefill.com/api/widget/country/\(forCountry.rawValue.uppercased())")!
        var sortedCategories = [BitrefillCategory]()
        var products = [BitrefillProduct]()
        
        Alamofire.request(url, method: .get).responseData(completionHandler: { response in
            guard
                let data = response.data,
                let json = try? JSON(data: data) else {
                    return
            }
            
            guard response.response?.statusCode == 200 else {
                if response.response?.statusCode == 400 {
                    viewController.showOKInfoAlert(
                        title: "Couldn't fetch data for \(forCountry.fullCountryName())",
                        message: json["message"].stringValue
                    )
                }
                
                return
            }
            
            let operatorsList = json["operators"]
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
