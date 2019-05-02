import UIKit
import FlexLayout

final class CreateWalletView: BaseFlexView {
    let logoImage: UIImageView
    let nameTextField: TextField
    let continueButton: LoadingButton
    
    required init() {
        let nameTextFieldFontSize = adaptiveLayout.getSize(forLarge: 22, forBig: 21, defaultSize: 20)
        
        logoImage = UIImageView(image: UIImage(named: "create_wallet_logo"))
        nameTextField = TextField(placeholder: NSLocalizedString("wallet_name", comment: ""), fontSize: Int(nameTextFieldFontSize))
        continueButton = PrimaryLoadingButton()
        continueButton.setTitle(NSLocalizedString("continue", comment: ""), for: .normal)
        super.init()
    }
    
    override func configureConstraints() {
        let margin = adaptiveLayout.getSize(forLarge: 100, forBig: 60, defaultSize: 40)
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .paddingTop(margin - 10)
            .define { flex in
                flex.addItem(logoImage).marginBottom(margin)
                flex.addItem(nameTextField).width(80%)
                flex.addItem(continueButton).position(.absolute).width(80%).height(50).bottom(25)
        }
    }
}
