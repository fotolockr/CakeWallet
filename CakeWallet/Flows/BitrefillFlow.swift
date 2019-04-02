import UIKit

final class BitrefillFlow {
    enum Route {
        case root
        case productList
//        case order
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)?
    
    private let navigationController: UINavigationController
    
    convenience init() {
        let bitrefillViewController = BitrefillBaseViewController(bitrefillFlow: nil)
        let navigationController = UINavigationController(rootViewController: bitrefillViewController)
        self.init(navigationController: navigationController)
        bitrefillViewController.bitrefillFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: Route? = nil, viewController: UIViewController? = nil) {
        if let withRoute = route {
            navigationController.pushViewController(initedViewController(for: withRoute), animated: true)
        }
        
        if let withVC = viewController {
            navigationController.pushViewController(withVC, animated: true)
        }
    }
    
    private func initedViewController(for route: Route, withVC: UIViewController? = nil) -> UIViewController {
        switch route {
        case .root:
            return BitrefillBaseViewController(bitrefillFlow: self)
        case .productList:
            return BitrefillProductListViewController(bitrefillFlow: self)
//        case .order:
//            return BitrefillOrderViewController()
        }
    }
}
