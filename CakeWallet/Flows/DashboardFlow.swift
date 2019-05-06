import UIKit
import CakeWalletLib
import CakeWalletCore
import CWMonero

final class DashboardFlow: Flow {
    enum Route {
        case start
        case wallets
        case send
        case receive
        case addressBook
        case subaddresses
        case addOrEditSubaddress(Subaddress?)
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    private var walletsFlow: WalletsFlow?
    
    convenience init() {
        let dashboardViewController = DashboardController(store: store, dashboardFlow: nil)
        let navigationController = UINavigationController(rootViewController: dashboardViewController)
        self.init(navigationController: navigationController)
        dashboardViewController.dashboardFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: DashboardFlow.Route) {
        switch route {
        case .start:
            navigationController.popToRootViewController(animated: true)
        case .receive:
            let receiveController = ReceiveViewController(store: store, dashboardFlow: self)
            let navController = UINavigationController(rootViewController: receiveController)
            presentPopup(navController)
        case .send:
            let sendViewController = SendViewController(store: store, address: nil)
            let navController = UINavigationController(rootViewController: sendViewController)
            presentPopup(navController)
        case .wallets:
            presentWallets()
        case .addressBook:
            let addressBook = AddressBookViewController(addressBook: AddressBook.shared, store: store, isReadOnly: false)
            navigationController.pushViewController(addressBook, animated: true)
        case .subaddresses:
            let subaddressesVC = SubaddressesViewController(store: store)
            subaddressesVC.flow = self
            navigationController.pushViewController(subaddressesVC, animated: true)
        case let .addOrEditSubaddress(sub):
            let subaddressVC = SubaddressViewController(flow: self, store: store, subaddress: sub)
            navigationController.pushViewController(subaddressVC, animated: true)
        }

    }
    
    private func presentWallets() {
        let walletsFlow = WalletsFlow()
        self.walletsFlow = walletsFlow
        presentPopup(walletsFlow.rootController)
    }
    
    private func presentPopup(_ viewController: UIViewController) {
        let rootViewController = navigationController.viewControllers.first
        let presenter = rootViewController?.tabBarController
        viewController.modalPresentationStyle = .custom
        presenter?.present(viewController, animated: true)
    }
}
