import UIKit
import FlexLayout

final class TermsView: BaseFlexView {
    let titleLabel: UILabel
    let textView: UITextView
    
    required init() {
        titleLabel = UILabel(fontSize: 14)
        textView = UITextView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        textView.backgroundColor = .clear
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.addItem(textView).height(100%).width(100%)
    }
}
