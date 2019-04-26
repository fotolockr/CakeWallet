import UIKit


final class ReceiveFlow: Flow {
    enum Route {
        case start
    }
    
    var rootController: UIViewController {
        return navigationViewController
    }
    private let navigationViewController: UINavigationController
    
    convenience init() {
        let receiveViewController = ReceiveViewController(store: store, receiveFlow: nil)
        let navigationViewController = UINavigationController(rootViewController: receiveViewController)
        self.init(navigationViewController: navigationViewController)
        receiveViewController.receiveFlow = self
    }
    
    init(navigationViewController: UINavigationController) {
        self.navigationViewController = navigationViewController
    }
    
    func change(route: ReceiveFlow.Route) {
        switch route {
        case .start:
            navigationViewController.popToRootViewController(animated: true)
        }
    }
}
