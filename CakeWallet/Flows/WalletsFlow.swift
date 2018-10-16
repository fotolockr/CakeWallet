import UIKit

final class WalletsFlow: Flow {
    enum Route {
        case start
        case showSeed(wallet: String, date: Date, seed: String)
        case showKeys
        case rescan
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    
    convenience init() {
        let walletViewController = WalletsViewController(store: store, walletsFlow: nil)
        let navigationController = UINavigationController(rootViewController: walletViewController)
        self.init(navigationController: navigationController)
        walletViewController.walletsFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func change(route: WalletsFlow.Route) {
        switch route {
        case .start:
            navigationController.popToRootViewController(animated: true)
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
        case .rescan:
            let rescanViewController = RescanViewController()
            navigationController.pushViewController(rescanViewController, animated: true)
        }
    }
}
