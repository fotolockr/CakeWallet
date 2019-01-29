import UIKit
import FlexLayout

final class FromKeysHeightView: BaseFlexView {
    let cardHolder: UIView
    let cardView: UIView
    let restoreFromHeightView: RestoreFromHeightView
    let doneButton: UIButton
    let actionButtonsContainer: UIView
    
    required init() {
        cardHolder = UIView()
        cardView = CardView()
        
        restoreFromHeightView = RestoreFromHeightView()
        doneButton = PrimaryButton(title: "Done")
        actionButtonsContainer = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        cardView.flex.padding(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 30)).define { flex in
            flex.addItem(restoreFromHeightView)
        }
        
        actionButtonsContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(doneButton).height(56).width(45%)
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
