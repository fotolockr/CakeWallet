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
    let addressBookButton: UIButton?
    let container: UIView
    let buttonsWrapper: UIView
    let firstButtonWrapper: UIView
    let lastButtonsWrapper: UIView
    
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
        addressBookButton = SecondaryButton(image: UIImage(named: "address_book_light_icon")?.resized(to: CGSize(width: 20, height: 20)))
        pasteButton = PasteButton(pastable: textView)
        container = UIView()
        buttonsWrapper = UIView()
        firstButtonWrapper = UIView()
        lastButtonsWrapper = UIView()
        super.init()
    }
    
    init(withQRScan showQRScanButton: Bool = true, withAddressBook showAddressBookButton: Bool = true) {
        textView = FloatingLabelTextView(placeholder: NSLocalizedString("address", comment: ""))
        addressBookButton = showAddressBookButton
            ? SecondaryButton(image: UIImage(named: "address_book_light_icon")?.resized(to: CGSize(width: 20, height: 20)))
            : nil
        qrScanButton = showQRScanButton
            ? SecondaryButton(image: UIImage(named: "qr_icon")?.resized(to: CGSize(width: 16, height: 16)))
            : nil
        pasteButton = PasteButton(pastable: textView)
        container = UIView()
        buttonsWrapper = UIView()
        firstButtonWrapper = UIView()
        lastButtonsWrapper = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        textView.isScrollEnabled = false
        backgroundColor = .clear
        qrScanButton?.addTarget(self, action: #selector(scanQr), for: .touchUpInside)
        addressBookButton?.addTarget(self, action: #selector(fromAddressBook), for: .touchUpInside)
    }
    
    override func configureConstraints() {
        firstButtonWrapper.flex.define { flex in
            flex.addItem(pasteButton).height(40).width(40)
        }
        
        lastButtonsWrapper.flex.alignItems(.center).define { flex in
            if let qrScanButton = qrScanButton {
                flex.addItem(qrScanButton).height(40).width(40).margin(UIEdgeInsets(top: 0, left: 10, bottom: 8, right: 0))
            }
            
            if let addressBookButton = addressBookButton {
                flex.addItem(addressBookButton).height(40).width(40).marginLeft(10)
            }
        }
        
        rootFlexContainer.flex.direction(.row).justifyContent(.spaceBetween).backgroundColor(.clear).define { flex in
            flex.addItem(textView).grow(1).height(56)
            
            flex.addItem(buttonsWrapper).define({ wrapperFlex in
                wrapperFlex
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .alignItems(.start)
                    .marginLeft(10)
                    .addItem(firstButtonWrapper)
                    
                wrapperFlex.addItem(lastButtonsWrapper)
            })
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
    
    @objc
    private func fromAddressBook() {
        let addressBookVC = AddressBookViewController(addressBook: AddressBook.shared, store: store, isReadOnly: true)
        addressBookVC.doneHandler = { [weak self] address in
            self?.textView.changeText(address)
        }
        let sendNavigation = UINavigationController(rootViewController: addressBookVC)
        presenter?.present(sendNavigation, animated: true)
    }
    
    private func updateAddress(from uri: QRUri) {
        textView.changeText(uri.address)
    }
}
