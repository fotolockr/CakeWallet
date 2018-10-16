import UIKit

protocol Pastable: class {
    func paste(text: String)
}

//extension UITextView: Pastable {
//    func paste(text: String) {
//        changeText(text)
//    }
//}

extension UITextField: Pastable {
    func paste(text: String) {
        self.text = text
    }
}

//extension FloatingLabelTextField: Pastable {
//    func paste(text: String) {
//        self.text = text
//    }
//}

extension FloatingLabelTextView: Pastable {
    func paste(text: String) {
        changeText(text)
    }
}

final class PasteButton: SecondaryButton {
    weak var pastable: Pastable?
    
    init(pastable: Pastable? = nil) {
        self.pastable = pastable
        super.init(image: UIImage(named: "paste_icon")?.resized(to: CGSize(width: 12, height: 20)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        addTarget(self, action: #selector(onTouchAction), for: .touchUpInside)
    }
    
    @objc
    private func onTouchAction() {
        if let text = UIPasteboard.general.string {
            guard let pastable = pastable else { return }
            pastable.paste(text: text)
        }
    }
}


