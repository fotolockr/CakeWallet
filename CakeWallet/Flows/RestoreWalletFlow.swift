import UIKit

final class RestoreWalletFlow: Flow {
    enum Route {
        case root
        case fromSeedWalletName
        case fromSeedSeed
        case fromSeedHeight
        
        case fromKeysWalletName
        case fromKeysKeys
        case fromKeysHeight
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
        case .fromSeedWalletName:
            return FromSeedWalletNameVC(restoreWalletFlow: self, wizzardStore: fromSeedWizzardStore)
        case .fromSeedSeed:
            return FromSeedSeedVC(restoreWalletFlow: self, wizzardStore: fromSeedWizzardStore)
        case .fromSeedHeight:
            return FromSeedHeightVC(restoreWalletFlow: self, store: store, wizzardStore: fromSeedWizzardStore)
        case .fromKeysWalletName:
            return FromKeysWalletNameVC(restoreWalletFlow: self, wizzardStore: fromKeysWizzardStore)
        case .fromKeysKeys:
            return FromKeysKeysVC(restoreWalletFlow: self, wizzardStore: fromKeysWizzardStore)
        case .fromKeysHeight:
            return FromKeysHeightVC(restoreWalletFlow: self, wizzardStore: fromKeysWizzardStore, store: store)
        }
    }
}
