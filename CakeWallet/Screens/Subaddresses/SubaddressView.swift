import UIKit
import FlexLayout

final class SubaddressView: BaseFlexView {
    let labelContainer: TextField
    let editButton: UIButton
    
    required init() {
        let labelTextFieldFontSize = adaptiveLayout.getSize(forLarge: 22, forBig: 21, defaultSize: 20)
        
        labelContainer = TextField(placeholder: NSLocalizedString("label", comment: ""), fontSize: Int(labelTextFieldFontSize))
        editButton = PrimaryButton(title: NSLocalizedString("edit", comment: ""))
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(labelContainer).width(80%)
                flex.addItem(editButton).position(.absolute).width(80%).height(50).bottom(25)
        }
    }
}
