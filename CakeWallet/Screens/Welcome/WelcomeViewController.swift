import UIKit

final class WelcomeViewController: BaseViewController<WelcomeView> {
    weak var signUpFlow: SignUpFlow?
    
    init(signUpFlow: SignUpFlow, restoreWalletFlow: RestoreWalletFlow) {
        self.signUpFlow = signUpFlow
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func configureBinds() {
        contentView.createWalletButton.addTarget(self, action: #selector(createWalletAction), for: .touchUpInside)
        contentView.restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        
        if let appName = Bundle.main.displayName {
            contentView.welcomeLabel.text = String(format: NSLocalizedString("welcome", comment: ""), appName).uppercased()
            contentView.welcomeSubtitleLabel.text = NSLocalizedString("first_wallet_text", comment: "")
        }
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        contentView.descriptionTextView.text = NSLocalizedString("please_make_selection", comment: "")
    }
    
    @objc
    private func createWalletAction() {
        signUpFlow?.change(route: .setupPin({ signUpFlow  in
            signUpFlow.change(route: .createWallet)
        }))
    }
    
    @objc
    private func restore() {
        signUpFlow?.change(route: .restoreRoot)
    }
}
