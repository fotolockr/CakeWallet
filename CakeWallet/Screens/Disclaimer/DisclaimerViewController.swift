import UIKit

final class DisclaimerViewController: BaseViewController<DisclaimerView> {
    var onAccept: ((UIViewController) -> Void)? = { vc in
        UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.termsOfUseAccepted)
        vc.dismiss(animated: true)
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("terms", comment: "")
        loadAndDisplayDocument()
        contentView.acceptButton.addTarget(self, action: #selector(onAccessAction), for: .touchUpInside)
        contentView.checkBoxTitleButton.addTarget(self, action: #selector(toggleCheckBox), for: .touchUpInside)
    }
    
    @objc
    private func onAccessAction() {
        if contentView.checkBox.isChecked {
            onAccept?(self)
        }
    }
    
    @objc
    func toggleCheckBox() {
        contentView.checkBox.isChecked = !contentView.checkBox.isChecked
    }
    
    private func loadAndDisplayDocument() {
        if let docUrl = Configurations.termsOfUseUrl {
            do {
                let attributedText = try NSAttributedString(
                    url: docUrl,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil)
                contentView.textView.attributedText = attributedText
            } catch {
                print(error) // fixme
            }
        }
    }
}
