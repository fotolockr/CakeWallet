import UIKit
import FlexLayout

final class RescanView: BaseFlexView {
    let cardView: CardView
    let restoreFromHeightView: RestoreFromHeightView
    let rescanButton: UIButton
    
    required init() {
        cardView = CardView()
        restoreFromHeightView = RestoreFromHeightView()
        rescanButton = PrimaryButton(title: NSLocalizedString("rescan", comment: ""))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).define { flex in
            flex.addItem(restoreFromHeightView)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceAround).padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(rescanButton).width(100%).height(56)
        }
    }
}
