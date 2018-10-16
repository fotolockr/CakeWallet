import UIKit
import QRCode
import FlexLayout

final class ShortReceiveViewController: BaseViewController<ShortReceiveView> {
    var address: String
    
    init(address: String) {
        self.address = address
        super.init()
    }
    
    override func configureBinds() {
        contentView.copyAddressButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        contentView.setNeedsLayout()
        let doneButton = StandartButton(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 10, height: 10)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 28, height: 28))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "share_icon")?.resized(to: CGSize(width: 20, height: 20)),
            style: .plain,
            target: self,
            action: #selector(shareAction))
        changeAddress(address)
    }
    
    func changeAddress(_ address: String) {
        let qrCode = QRCode(address)
        contentView.addressLabel.text = address
        contentView.qrImage.image = qrCode?.image
        contentView.addressLabel.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    @objc
    private func shareAction() {
        let activityViewController = UIActivityViewController(
            activityItems: [address],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.message, UIActivityType.mail,
            UIActivityType.print, UIActivityType.copyToPasteboard]
        present(activityViewController, animated: true)
    }
    
    @objc
    private func copyAction() {
        showInfo(title: NSLocalizedString("copied", comment: ""), withDuration: 1, actions: [])
        UIPasteboard.general.string = address
    }
}


final class ShortReceiveView: BaseFlexView {
    let cardView: CardView
    let qrImage: UIImageView
    let addressLabel: UILabel
    let copyAddressButton: UIButton

    
    required init() {
        cardView = CardView()
        qrImage = UIImageView()
        addressLabel = UILabel(fontSize: 14)
        copyAddressButton = PrimaryButton(title: "copy_address")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        rootFlexContainer.backgroundColor = .clear
        isOpaque = true
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
    }
    
    override func configureConstraints() {
        cardView.flex.alignItems(.center).padding(20, 20, 30, 20).define { flex in
            flex.addItem(qrImage).size(CGSize(width: 160, height: 160))
            flex.addItem(addressLabel).marginTop(10)
            flex.addItem(copyAddressButton).marginTop(10).height(56).width(160)
        }
        
        rootFlexContainer.flex.padding(20).justifyContent(.center).define { flex in
            flex.addItem(cardView).width(100%)
        }
    }
}
