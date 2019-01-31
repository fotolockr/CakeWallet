import UIKit
import FlexLayout

final class FromSeedSeedView: BaseFlexView {
    let cardHolder: UIView
    let cardView: UIView
    let seedTextField: UITextField
    let nextButton: UIButton
    let actionButtonsContainer: UIView
    let pasteButton: PasteButton
    
    required init() {
        cardHolder = UIView()
        cardView = CardView()
        
        seedTextField = FloatingLabelTextField(placeholder: "Seed")
        nextButton = PrimaryButton(title: "Next")
        actionButtonsContainer = UIView()
        pasteButton = PasteButton(pastable: seedTextField)
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        cardView.flex.direction(.row).justifyContent(.spaceBetween)
            .padding(UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)).define { flex in
                flex.addItem(seedTextField).grow(1).height(50)
                flex.addItem(pasteButton).width(40).height(40).marginLeft(10)
        }
        
        actionButtonsContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(nextButton).height(56).width(45%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)).define { flex in
                flex.addItem(cardHolder).justifyContent(.center).width(100%).height(90%)
                    .addItem(cardView).justifyContent(.center).width(100%)
                flex.addItem(actionButtonsContainer).width(100%)
        }
    }
}
