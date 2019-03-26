import UIKit
import FlexLayout
import CakeWalletCore

// fixme: Replace me

extension UIViewController {
    
    var isModal: Bool {
        return presentingViewController != nil ||
            navigationController?.presentingViewController?.presentedViewController === navigationController ||
            tabBarController?.presentingViewController is UITabBarController
    }
    
}

final class SetupPinViewController: BaseViewController<BaseFlexView> {
    let pinCodeViewController: PinCodeViewController
    let store: Store<ApplicationState>
    weak var signUpFlow: SignUpFlow?
    var afterPinSetup: (() -> Void)?
    private var rememberedPin: PinCodeViewController.PinCode
    let togglePingLengthBtn: UIBarButtonItem
    
    init(store: Store<ApplicationState>) {
        self.store = store
        self.pinCodeViewController = PinCodeViewController()
        rememberedPin = []
        togglePingLengthBtn = UIBarButtonItem()
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.rootFlexContainer.flex.define({ flex in
            flex.addItem(pinCodeViewController.contentView).height(100%).width(100%)
        })
    }
    
    override func configureBinds() {
        togglePingLengthBtn.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 16)!,
            NSAttributedStringKey.foregroundColor: Theme.current.lightText], for: .normal)
        togglePingLengthBtn.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 16)!,
            NSAttributedStringKey.foregroundColor: Theme.current.lightText], for: .highlighted)
        
        title = NSLocalizedString("setup_pin", comment: "")
        togglePingLengthBtn.title = NSLocalizedString("use_6_pin", comment: "")
        togglePingLengthBtn.style = .plain
        togglePingLengthBtn.target = self
        togglePingLengthBtn.action = #selector(useSixDigitsPin)
        
        navigationItem.rightBarButtonItem = togglePingLengthBtn
        pinCodeViewController.contentView.titleLabel.text = NSLocalizedString("create_pin", comment: "")
        
        pinCodeViewController.handler = { [weak self] pin in
            guard let this = self else {
                return
            }
            
            if this.rememberedPin.isEmpty {
                this.rememberedPin = pin
                this.pinCodeViewController.contentView.titleLabel.text = NSLocalizedString("re_enter_your_pin", comment: "")
                this.pinCodeViewController.cleanPin()
            } else if this.rememberedPin == pin {
                let pinLength = this.pinCodeViewController.pinLength
                
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                    this.store.dispatch(
                        SettingsActions.setPin(pin: pin.string(), length: pinLength)
                    )
                    
                    this.pinCodeViewController.cleanPin()
                    this.afterPinSetup?()
                })
                
                this.showInfoAlert(title: NSLocalizedString("pin_setup_success", comment: ""), actions: [okAction])
            } else {
                this.showError(title: NSLocalizedString("incorrect_pin", comment: ""))
                this.pinCodeViewController.contentView.titleLabel.text = NSLocalizedString("create_pin", comment: "")
                this.rememberedPin = []
                this.pinCodeViewController.cleanPin()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isModal = self.isModal
        guard isModal else { return }
        
        let doneButton = StandartButton.init(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 10, height: 10)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 28, height: 28))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    @objc
    private func useFourDigitsPin() {
        pinCodeViewController.changePin(length: .fourDigits)
        togglePingLengthBtn.action = #selector(useSixDigitsPin)
        togglePingLengthBtn.title = NSLocalizedString("use_6_pin", comment: "")
        
    }
    
    @objc
    private func useSixDigitsPin() {
        pinCodeViewController.changePin(length: .sixDigits)
        togglePingLengthBtn.action = #selector(useFourDigitsPin)
        togglePingLengthBtn.title = NSLocalizedString("use_4_pin", comment: "")
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
}
