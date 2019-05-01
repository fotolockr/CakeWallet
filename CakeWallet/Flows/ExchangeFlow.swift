import UIKit
import CakeWalletLib

final class ExchangeFlow: Flow {
    enum Route {
        case start
        case exchangeResult(Trade, Amount)
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    
    convenience init() {
        let exchangeViewController = ExchangeViewController(store: store, exchangeFlow: nil)
        let navigationController = UINavigationController(rootViewController: exchangeViewController)
        self.init(navigationController: navigationController)
        exchangeViewController.exchangeFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: ExchangeFlow.Route) {
        switch route {
        case .start:
            navigationController.popToRootViewController(animated: true)
        case let .exchangeResult(trade, amount):
            let exchangeResultViewController = ExchangeResultViewController(trade: trade, amount: amount)
            navigationController.pushViewController(exchangeResultViewController, animated: true)
        }
    }
}
