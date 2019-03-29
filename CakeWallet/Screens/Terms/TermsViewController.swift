import UIKit

final class TermsViewController: BaseViewController<TermsView> {
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("terms", comment: "")
        loadAndDisplayDocument()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOKInfoAlert(title: NSLocalizedString("terms", comment: ""), message: NSLocalizedString("terms_accepting_message", comment: ""))
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
