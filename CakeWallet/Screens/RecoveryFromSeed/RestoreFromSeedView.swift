import UIKit
import FlexLayout

final class RestoreFromSeedView: BaseScrollFlexViewWithBottomSection {
    let cardView: CardView
    let walletTextField: UITextField
    let restoreFromHeightView: RestoreFromHeightView
    let seedTextField: FloatingLabelTextView
    let recoverButton: UIButton
    let seedTextFieldWrapperView: UIView
    
    required init() {
        cardView = CardView()
        walletTextField = FloatingLabelTextField(
            placeholder: NSLocalizedString("enter_wallet_name", comment: ""),
            title:  NSLocalizedString("wallet_name", comment: ""))
        restoreFromHeightView = RestoreFromHeightView()
        seedTextField = FloatingLabelTextView(placeholder: NSLocalizedString("seed", comment: ""))
        recoverButton = PrimaryButton(title: NSLocalizedString("restore", comment: ""))
        seedTextFieldWrapperView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        seedTextField.autocapitalizationType  = .none
        seedTextField.delegate = self
        seedTextField.isScrollEnabled = false
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20, 20, 30, 20).define { flex in
            flex.addItem(walletTextField).height(50)
            flex.addItem(restoreFromHeightView)
            flex.addItem(seedTextFieldWrapperView).direction(.row)
                .addItem(seedTextField).marginTop(10).width(100%).height(56).grow(1)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceBetween).padding(20).define { flex in
            flex.addItem(cardView).width(100%)
        }
        
        bottomSectionView.flex.padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(recoverButton).width(100%).height(56)
        }
    }
}
