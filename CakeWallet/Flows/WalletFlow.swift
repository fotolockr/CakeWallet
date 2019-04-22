import UIKit

final class CustomTabBarController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedViewController?.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedViewController?.viewWillDisappear(animated)
    }
}

final class WalletFlow: NSObject, Flow, UITabBarControllerDelegate {
    
    
    enum Route {
        case start
    }
    
    var rootController: UIViewController {
        return _root
    }
    
    let _root: UITabBarController
    
    private lazy var dashboardFlow: DashboardFlow = {
        return DashboardFlow()
    }()
    
    private lazy var settingsFlow: SettingsFlow = {
       return SettingsFlow()
    }()
    
    private lazy var exchangeFlow: ExchangeFlow = {
        return ExchangeFlow()
    }()
    
    private lazy var bitrefillFlow: BitrefillFlow = {
        return BitrefillFlow()
    }()
    
    convenience override init() {
        let tabbarController = CustomTabBarController()
        self.init(rootController: tabbarController)
    }
    
    init(rootController: UITabBarController) {
        self._root = rootController
        super.init()
        configureRootTabBar()
        _root.delegate = self
    }
    
    func change(route: Route) {
        switch route {
        case .start:
            _root.selectedIndex = 0
        }
    }
    
    private func configureRootTabBar() {
        _root.viewControllers = [
            dashboardFlow.rootController,
            exchangeFlow.rootController,
            bitrefillFlow.rootController,
            settingsFlow.rootController
        ]
    }
}
