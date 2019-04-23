import UIKit
import CakeWalletLib
import CakeWalletCore
import CWMonero

final class ReceiveFlow: Flow {
    enum Route {
        case start
        case subaddresses
        case editSubaddress(Subaddress)
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
        case .subaddresses:
            let subaddressesVC = SubaddressesViewController(store: store)
            subaddressesVC.flow = self
            navigationViewController.pushViewController(subaddressesVC, animated: true)
        case let .editSubaddress(sub):
            let subaddressVC = SubaddressViewController(store: store, subaddress: sub)
            navigationViewController.pushViewController(subaddressVC, animated: true)
        }
    }
}
