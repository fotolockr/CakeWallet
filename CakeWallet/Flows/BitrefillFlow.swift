import UIKit

final class BitrefillFlow: Flow {
    enum Route {
        case root
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)?
    
    private let navigationController: UINavigationController
    
    convenience init() {
        let bitrefillViewController = BitrefillBaseViewController()
        let navigationController = UINavigationController(rootViewController: bitrefillViewController)
        self.init(navigationController: navigationController)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: Route) {
        navigationController.pushViewController(initedViewController(for: route), animated: true)
    }
    
    private func initedViewController(for route: Route) -> UIViewController {
        switch route {
        case .root:
            return BitrefillBaseViewController()
        }
    }
}
