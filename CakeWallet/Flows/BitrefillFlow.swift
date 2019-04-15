import UIKit


final class BitrefillFlow: Flow {
    enum Route {
        case selectCountry
        case selectCategory
        case productsList([BitrefillProduct])
        case productDetails(BitrefillProduct)
        case order(BitrefillOrderDetails)
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)?
    private let navigationController: UINavigationController
    
    convenience init() {
        let selectCategoryViewController = BitrefillSelectCategoryViewController(bitrefillFlow: nil, categories: [], products: [])
        let navigationController = UINavigationController(rootViewController: selectCategoryViewController)
        
        self.init(navigationController: navigationController)
        selectCategoryViewController.bitrefillFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: BitrefillFlow.Route) {
        switch route {
        case .selectCategory:
            navigationController.pushViewController(
                BitrefillSelectCategoryViewController(bitrefillFlow: self, categories: [], products: []),
                animated: true
            )
        case .selectCountry:
            let bitrefillSelectCountryViewController = BitrefillSelectCountryViewController(bitrefillFlow: self)
            bitrefillSelectCountryViewController.delegate = navigationController.viewControllers.first as? BitrefillSelectCountryDelegate
            let navController = UINavigationController(rootViewController: bitrefillSelectCountryViewController)
            presentPopup(navController)
            
        case let .productsList(list):
            navigationController.pushViewController(
                BitrefillProductListViewController(bitrefillFlow: self, products: list),
                animated: true
            )
            
        case let .productDetails(productDetails):
            navigationController.pushViewController(
                BitrefillProductDetailsViewController(bitrefillFlow: self, productDetails: productDetails),
                animated: true
            )
            
        case let .order(orderDetails):
            navigationController.pushViewController(
                BitrefillOrderViewController(bitrefillFlow: self, orderDetails: orderDetails),
                animated: true
            )
        }
    }
    
    private func presentPopup(_ viewController: UIViewController) {
        let rootViewController = navigationController.viewControllers.first
        let presenter = rootViewController?.tabBarController
        viewController.modalPresentationStyle = .custom
        presenter?.present(viewController, animated: true)
    }
}
