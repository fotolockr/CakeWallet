import UIKit
import FlexLayout

final class CreateWalletView: BaseFlexView {
    let nameTextField: UITextField
    let continueButton: LoadingButton
    
    required init() {
        nameTextField = FloatingLabelTextField(placeholder: NSLocalizedString("wallet_name", comment: ""))
        continueButton = PrimaryLoadingButton(type: .custom)
        continueButton.setTitle(NSLocalizedString("continue", comment: ""), for: .normal)
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(nameTextField).height(50).width(80%)
            flex.addItem(continueButton).position(.absolute).width(80%).height(50).bottom(25)
        }
    }
}
