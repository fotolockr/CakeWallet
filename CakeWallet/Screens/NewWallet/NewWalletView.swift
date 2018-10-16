import UIKit
import FlexLayout

final class NewWalletView: BaseFlexView {
    let imageView: UIImageView
    let createWallet: UIButton
    let recoveryWallet: UIButton
    
    required init() {
        imageView = UIImageView(image: UIImage(named: "new_wallet_logo"))
        createWallet = PrimaryButton(title: NSLocalizedString("create_new", comment: ""))
        recoveryWallet = SecondaryButton(title: NSLocalizedString("restore", comment: ""))
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(imageView).width(256).height(223)
            flex.addItem(createWallet).height(56).marginBottom(25).width(80%)
            flex.addItem(recoveryWallet).height(56).width(80%)
        }
    }
}
