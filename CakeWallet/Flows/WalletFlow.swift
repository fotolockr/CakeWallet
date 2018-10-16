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
//            UINavigationController(rootViewController: ReceivePageViewController(
//                transitionStyle: .scroll,
//                navigationOrientation: .horizontal,
//                options: nil
//                )
//            ),
//            UINavigationController(rootViewController: SendViewController(store: store)),
            exchangeFlow.rootController,
            settingsFlow.rootController
//            UINavigationController(rootViewController: SettingsViewController(store: store))
        ]
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        guard
//            let nav = viewController as? UINavigationController,
//            let viewController = nav.viewControllers.first as? DashboardController else { return }
//
//        if let nav = viewController.presentedViewController as? UINavigationController {
//            nav.viewControllers.first?.dismiss(animated: true)
//        } else {
//            viewController.presentedViewController?.dismiss(animated: true)
//            viewController.view.subviews.forEach { view in
//                    if view.tag == blurViewTag {
//                        view.removeFromSuperview()
//                    }
//            }
//        }
//        viewController.navigationItem.titleView?.isHidden = false
//        viewController.navigationItem.rightBarButtonItem = viewController.syncButton
//    }
}
