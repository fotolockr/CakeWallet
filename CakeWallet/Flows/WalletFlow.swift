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
        tabBar.layer.applySketchShadow(color: UIColor(red: 52, green: 115, blue: 176), alpha: 0.2, x: 0, y: 18, blur: 44, spread: 18)
        tabBar.layer.masksToBounds = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 90
        self.tabBar.frame = tabFrame
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
            settingsFlow.rootController
        ]
    }
}
