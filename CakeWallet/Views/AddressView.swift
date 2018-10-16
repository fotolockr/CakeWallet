import UIKit
import FlexLayout
import QRCodeReader
import CakeWalletLib

//fixme

protocol QRUriUpdateResponsible: class {
    func getCrypto(for adressView: AddressView) -> CryptoCurrency
    func update(uri: QRUri)
}

//fixme

extension UITextView {
    func changeText(_ text: String) {
        self.text = text
        self.delegate?.textViewDidChange?(self)
    }
}

final class AddressView: BaseFlexView {
    let textView: FloatingLabelTextView
    let qrScanButton: UIButton?
    let pasteButton: PasteButton
    let container: UIView
    
    weak var presenter: UIViewController?
    weak var updateResponsible: QRUriUpdateResponsible?
    
    private lazy var QRReaderVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    required init() {
        textView = FloatingLabelTextView(placeholder: NSLocalizedString("address", comment: ""))
        qrScanButton = SecondaryButton(image: UIImage(named: "qr_icon")?
            .resized(to: CGSize(width: 16, height: 16)))
        pasteButton = PasteButton(pastable: textView)
        container = UIView()
        super.init()
    }
    
    
    init(withQRScan showQRScanButton: Bool = true) {
        textView = FloatingLabelTextView(placeholder: NSLocalizedString("address", comment: ""))
        qrScanButton = showQRScanButton
            ? SecondaryButton(image: UIImage(named: "qr_icon")?
                .resized(to: CGSize(width: 16, height: 16)))
            : nil
        pasteButton = PasteButton(pastable: textView)
        container = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isScrollEnabled = false
        backgroundColor = .clear
        qrScanButton?.addTarget(self, action: #selector(scanQr), for: .touchUpInside)
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.direction(.row).backgroundColor(.clear).define { flex in
            flex.addItem(textView).grow(1).height(56)
            
            if let qrScanButton = qrScanButton {
                flex.addItem(qrScanButton).height(40).width(40).margin(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            }
            
            flex.addItem(pasteButton).height(40).width(40)
        }
    }
    
    @objc
    private func scanQr() {
        QRReaderVC.completionBlock = { [weak self] result in
            guard let this = self else {
                return
            }
            
            if
                let value = result?.value,
                let crypto = this.updateResponsible?.getCrypto(for: this) {
                let uri: QRUri
                
                switch crypto {
                case .bitcoin:
                    uri = BitcoinQRResult(uri: value)
                case .monero:
                    uri = MoneroQRResult(uri: value)
                default:
                    uri = DefaultCryptoQRResult(uri: value, for: crypto)
                }
                
                this.updateAddress(from: uri)
                this.updateResponsible?.update(uri: uri)
            }
            
            this.QRReaderVC.stopScanning()
            this.QRReaderVC.dismiss(animated: true)
        }
        
        QRReaderVC.modalPresentationStyle = .overFullScreen
        presenter?.parent?.present(QRReaderVC, animated: true)
    }
    
    private func updateAddress(from uri: QRUri) {
        textView.changeText(uri.address)
    }
}
