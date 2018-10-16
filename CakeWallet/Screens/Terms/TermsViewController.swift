import UIKit

final class TermsViewController: BaseViewController<TermsView> {
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("terms", comment: "")
        loadAndDisplayDocument()
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
