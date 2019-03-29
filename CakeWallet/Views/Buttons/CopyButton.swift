import UIKit

final class CopyButton: SecondaryButton {
    var textHandler: (() -> String)?
    weak var alertPresenter: UIViewController?
    
    override func configureView() {
        super.configureView()
        addTarget(self, action: #selector(onTouchAction), for: .touchUpInside)
    }
    
    @objc
    private func onTouchAction() {
        guard
            let text = textHandler?(),
            !text.isEmpty else { return }
        UIPasteboard.general.string = text
        alertPresenter?.showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
    }
}
