import UIKit
import FlexLayout

final class DisclaimerView: BaseFlexView {
    let titleLabel: UILabel
    let textView: UITextView
    let bottomView: UIView
    let acceptButton: UIButton
    let rejectButton: UIButton
    let checkBox: CheckBox
    
    required init() {
        titleLabel = UILabel(fontSize: 14)
        textView = UITextView()
        bottomView = UIView()
        acceptButton = PrimaryButton(title: "Accept")
        rejectButton = SecondaryButton(title: "Reject")
        checkBox = CheckBox()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        textView.backgroundColor = .clear
    }
    
    override func configureConstraints() {
        bottomView.flex.define { flex in
//            flex.addItem(rejectButton).height(56).width(100%).marginBottom(10)
            flex.addItem(checkBox)
            flex.addItem(acceptButton).height(56).width(100%)
        }
        
        rootFlexContainer.flex.alignItems(.center).padding(0, 15, 15, 15).define{ flex in
            flex.addItem(textView).marginBottom(10).marginBottom(150)
            flex.addItem(bottomView).height(150).position(.absolute).bottom(0).width(100%)
        }
    }
}
