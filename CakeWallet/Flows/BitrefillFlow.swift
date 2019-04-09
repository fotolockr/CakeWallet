import UIKit

final class BitrefillFlow: Flow {
    enum Route {
        case selectCountry
        case productsList([BitrefillProduct])
        case root
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)?
    private let navigationController: UINavigationController
    
    convenience init() {
        let bitrefillViewController = BitrefillBaseViewController(bitrefillFlow: nil, categories: [], products: [])
        let navigationController = UINavigationController(rootViewController: bitrefillViewController)
        self.init(navigationController: navigationController)
        bitrefillViewController.bitrefillFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: BitrefillFlow.Route) {
        switch route {
        case .root:
            navigationController.pushViewController(
                BitrefillBaseViewController(bitrefillFlow: self, categories: [], products: []),
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
        }
    }
    
    private func presentPopup(_ viewController: UIViewController) {
        let rootViewController = navigationController.viewControllers.first
        let presenter = rootViewController?.tabBarController
        viewController.modalPresentationStyle = .custom
        presenter?.present(viewController, animated: true)
    }
}
