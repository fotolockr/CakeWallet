import UIKit
import FlexLayout

final class DisclaimerView: BaseFlexView {
    let titleLabel: UILabel
    let textView: UITextView
    let bottomView: UIView
    let acceptButton: UIButton
    let rejectButton: UIButton
    
    required init() {
        titleLabel = UILabel(fontSize: 14)
        textView = UITextView()
        bottomView = UIView()
        acceptButton = PrimaryButton(title: "Accept", font: UIFont.systemFont(ofSize: 14))
        rejectButton = SecondaryButton(title: "Reject", font: UIFont.systemFont(ofSize: 14))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        textView.backgroundColor = .clear
    }
    
    override func configureConstraints() {
        
        bottomView.flex.padding(15).define { flex in
            flex.addItem(rejectButton).height(56).width(100%).marginBottom(10)
            flex.addItem(acceptButton).height(56).width(100%)
        }
        
        rootFlexContainer.flex.define{ flex in
            flex.addItem(textView).marginBottom(10).marginBottom(150)
            flex.addItem(bottomView).height(150).position(.absolute).bottom(0).width(100%)
        }
    }
}
