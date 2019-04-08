import UIKit

final class BitrefillFlow {
    enum Route {
        case selectCountry
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
    
    func change(route: Route? = nil, viewController: UIViewController? = nil) {
        if let withRoute = route {
            switch withRoute {
            case .root:
                navigationController.pushViewController(
                    BitrefillBaseViewController(bitrefillFlow: self, categories: [], products: []),
                    animated: true
                )
            case .selectCountry:
                let navController = UINavigationController(rootViewController: BitrefillSelectCountryViewController(bitrefillFlow: self))
                presentPopup(navController)
            }
        }
        
        if let withVC = viewController {
            navigationController.pushViewController(withVC, animated: true)
        }
    }
    
    private func presentPopup(_ viewController: UIViewController) {
        let rootViewController = navigationController.viewControllers.first
        let presenter = rootViewController?.tabBarController
        viewController.modalPresentationStyle = .custom
        presenter?.present(viewController, animated: true)
    }
}
