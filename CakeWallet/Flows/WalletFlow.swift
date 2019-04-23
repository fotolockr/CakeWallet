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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.clipsToBounds = true
    
        tabBar.backgroundColor = UIColor.white
        tabBar.layer.backgroundColor = UIColor.white.cgColor
        tabBar.barTintColor = UIColor.white
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.masksToBounds = false
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
