import UIKit
import FlexLayout

extension UITextView {
    private static let placeholderTag = 100
    
    var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(UITextView.placeholderTag) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(UITextView.placeholderTag) as? UILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(UITextView.placeholderTag) as? UILabel {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = applyFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.wildDarkBlue
        placeholderLabel.tag = UITextView.placeholderTag

        placeholderLabel.isHidden = self.text.count > 0

        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
}
