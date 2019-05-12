import UIKit
import FlexLayout

final class SubaddressView: BaseFlexView {
    let labelContainer: CWTextField
    let editButton: UIButton
    
    required init() {
        labelContainer = CWTextField(placeholder: NSLocalizedString("subaddresses", comment: ""))
        labelContainer.font = applyFont(ofSize: 17)
        editButton = PrimaryButton(title: NSLocalizedString("edit", comment: ""))
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(labelContainer).width(80%)
                flex.addItem(editButton).position(.absolute).width(85%).height(56).bottom(25)
        }
    }
}
