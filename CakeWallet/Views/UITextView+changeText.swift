import UIKit

extension UITextView {
    func changeText(_ text: String) {
        self.text = text
        self.delegate?.textViewDidChange?(self)
    }
}
