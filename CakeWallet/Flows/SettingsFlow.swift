import UIKit
import FlexLayout

final class SettingsFlow: Flow {
    enum Route {
        case start
        case nodes
        case changePin
        case changeLanguage
        case terms
        case addressBook
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    private var nodesFlow: NodesFlow?
    
    convenience init() {
        let settingsViewController = SettingsViewController(store: store, settingsFlow: nil)
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        self.init(navigationController: navigationController)
        settingsViewController.settingsFlow = self
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func change(route: SettingsFlow.Route) {
        switch route {
        case .start:
            navigationController.popToRootViewController(animated: true)
        case .nodes:
            presentNodes()
        case .changePin:
            let setupPinViewController = SetupPinViewController(store: store)
            setupPinViewController.afterPinSetup = { [weak setupPinViewController] in
                setupPinViewController?.dismiss(animated: true)
            }
            
            if navigationController.viewControllers.count > 0 {
                navigationController.popToRootViewController(animated: true)
            }
            
            navigationController.viewControllers.first?.present(
                UINavigationController(rootViewController: setupPinViewController),
                animated: true
            )
        case .changeLanguage:
            let changeLanguage = ChangeLanguageViewController()
            navigationController.pushViewController(changeLanguage, animated: true)
        case .terms:
            let termsViewController = TermsViewController()
            navigationController.pushViewController(termsViewController, animated: true)
        case .addressBook:
            let addressBook = AddressBookViewController(addressBoook: AddressBook.shared)
            navigationController.pushViewController(addressBook, animated: true)
        }
    }
    
    private func presentNodes() {
        let nodesFlow = NodesFlow(navigationController: navigationController)
        self.nodesFlow = nodesFlow
        nodesFlow.change(route: .start)
    }
}
