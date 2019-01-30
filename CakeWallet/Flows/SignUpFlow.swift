import UIKit

final class SignUpFlow: Flow {
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
    
    var doneHandler: (() -> Void)?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
            return WelcomeViewController(signUpFlow: self)
        case .newWallet:
            return NewWalletViewController(signUpFlow: self)
        case let .setupPin(handler):
            let setupPinController = SetupPinViewController(store: store)
            setupPinController.afterPinSetup = { handler?(self) }
            return setupPinController
        case .createWallet:
            return CreateWalletViewController(signUpFlow: self, store: store)
        case .restore:
            return RestoreViewController(signUpFlow: self)
        case .restoreFromKeys:
            return RestoreFromKeysViewController(signUpFlow: self, store: store)
        case .restoreFromSeed:
            return RestoreFromSeedViewController(signUpFlow: self, store: store)
        case let .seed(date, walletName, seed):
            let seedViewController = SeedViewController(walletName: walletName, date: date, seed: seed, doneFlag: true)
            seedViewController.doneHandler = doneHandler
            return seedViewController
        case .restoreFromCloud:
            let restoreFromCloudVC = RestoreFromCloudVC(backup: BackupServiceImpl(), storage: ICloudStorage())
            restoreFromCloudVC.doneHandler = doneHandler
            return restoreFromCloudVC
        }
    }
}
