import UIKit

final class RestoreWalletFlow: Flow {
    enum Route {
        case root
        case recoverFromSeed
        case recoverFromKeys
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)?
    
    let fromSeedWizzardStore = WizzardStore(state: WizzardRestoreFromSeedState(name: "", seed: "", height: nil, date: ""))
    let fromKeysWizzardStore = WizzardStore(state: WizzardRestoreFromKeysState(name: "", address: "", viewKey: "", spendKey: "", height: nil, date: ""))
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: Route) {
        navigationController.pushViewController(initedViewController(for: route), animated: true)
    }
    
    private func initedViewController(for route: Route) -> UIViewController {
        switch route {
        case .root:
            return RestoreVC(restoreWalletFlow: self)
        case .recoverFromSeed:
            return RecoverFromSeedViewCntroller(store: store, restoreWalletFlow: self)
        case .recoverFromKeys:
            return RecoverFromKeysViewController(store: store, restoreWalletFlow: self)
        }
    }
}
