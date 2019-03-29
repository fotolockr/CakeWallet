import UIKit

final class MiniCopyButton: SecondaryButton {
    weak var textField: UITextField?
    weak var alertPresenter: UIViewController?
    
    init(textField: UITextField? = nil) {
        self.textField = textField
        super.init(image: UIImage(named: "copy_icon")?.resized(to: CGSize(width: 16, height: 16)))
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
        guard
            let text = textField?.text,
            !text.isEmpty else { return }
        UIPasteboard.general.string = text
        alertPresenter?.showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), duration: 1)
    }
}
