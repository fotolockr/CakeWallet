import UIKit

final class SignUpFlow: Flow {
    let restoreWalletFlow: RestoreWalletFlow
    
    enum Route {
        case disclaimer
        case welcome
        case newWallet
        case setupPin(((SignUpFlow) -> Void)?)
        case createWallet
        case restore
        case restoreFromSeed
        case restoreFromKeys
        case restoreFromCloud
        case seed(Date, String, String)
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    var doneHandler: (() -> Void)? {
        didSet {
            self.restoreWalletFlow.doneHandler = doneHandler
        }
    }
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, restoreWalletFlow: RestoreWalletFlow) {
        self.navigationController = navigationController
        self.restoreWalletFlow = restoreWalletFlow
    }
    
    func change(route: Route) {
        navigationController.pushViewController(initedViewController(for: route), animated: true)
    }
    
    private func initedViewController(for route: Route) -> UIViewController {
        switch route {
        case .disclaimer:
            let vc = DisclaimerViewController()
            vc.onAccept = { [weak self] _ in
                UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.termsOfUseAccepted)
                self?.change(route: .welcome)
            }
            
            return vc
        case .welcome:
            return WelcomeViewController(signUpFlow: self, restoreWalletFlow: restoreWalletFlow)
        case .newWallet:
            return NewWalletViewController(signUpFlow: self, restoreWalletFlow: restoreWalletFlow)
        case let .setupPin(handler):
            let setupPinController = SetupPinViewController(store: store)
            setupPinController.afterPinSetup = { handler?(self) }
            return setupPinController
        case .createWallet:
            return CreateWalletViewController(signUpFlow: self, store: store)
        case let .seed(date, walletName, seed):
            let seedViewController = SeedViewController(walletName: walletName, date: date, seed: seed, doneFlag: true)
            seedViewController.doneHandler = doneHandler
            return seedViewController
        case .restoreFromCloud:
            let restoreFromCloudVC = RestoreFromCloudVC(backup: BackupServiceImpl(), storage: ICloudStorage())
            restoreFromCloudVC.doneHandler = doneHandler
            return restoreFromCloudVC
        case .restore:
            return UIViewController()
        case .restoreFromSeed:
            return UIViewController()
        case .restoreFromKeys:
            return UIViewController()
        }
    }
}
