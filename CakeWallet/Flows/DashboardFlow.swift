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
         case showSeed(wallet: String, date: Date, seed: String)
        case showKeys
        case addressBook
        case subaddresses
        case addOrEditSubaddress(Subaddress?)
        case accounts
        case addOrEditAccount(Account?)
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    private var walletsFlow: WalletsFlow?
    private weak var receiveVC: UIViewController?
    
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
            receiveVC = receiveController
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
        case let .showSeed(wallet, date, seed):
            let seedViewController = SeedViewController(walletName: wallet, date: date, seed: seed, doneFlag: true)
            seedViewController.doneHandler = { [weak seedViewController] in
                seedViewController?.dismiss(animated: true)
            }
            let navigationController = UINavigationController(rootViewController: seedViewController)
            self.navigationController.viewControllers.first?.present(navigationController, animated: true)
        case .showKeys:
            let keysViewController = ShowKeysViewController(store: store)
            let navigationController = UINavigationController(rootViewController: keysViewController)
            self.navigationController.viewControllers.first?.present(navigationController, animated: true)
        case .subaddresses:
            let subaddressesVC = SubaddressesViewController(store: store)
            subaddressesVC.flow = self
            navigationController.pushViewController(subaddressesVC, animated: true)
        case let .addOrEditSubaddress(sub):
            let subaddressVC = SubaddressViewController(flow: self, store: store, subaddress: sub)
            receiveVC?.navigationController?.pushViewController(subaddressVC, animated: true)
        case .accounts:
            let accountsVC = AccountsViewController(store: store)
            accountsVC.flow = self
            navigationController.pushViewController(accountsVC, animated: true)
        case let .addOrEditAccount(account):
            let accountVC = AccountViewController(flow: self, store: store, account: account)
            navigationController.pushViewController(accountVC, animated: true)
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
