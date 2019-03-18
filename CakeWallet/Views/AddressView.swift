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
    let textView: UITextField
    let borderView, buttonsView: UIView
    let qrScanButton, addressBookButton: UIButton
    let placeholder: String
    let hideAddressBookButton: Bool

    weak var presenter: UIViewController?
    weak var updateResponsible: QRUriUpdateResponsible?
    
    private lazy var QRReaderVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    required init(placeholder: String, hideAddressBookButton: Bool = false) {
        self.placeholder = placeholder
        self.hideAddressBookButton = hideAddressBookButton
        textView = UITextField()
        borderView = UIView()
        buttonsView = UIView()
        qrScanButton = UIButton()
        addressBookButton = UIButton()
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        qrScanButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        qrScanButton.backgroundColor = .clear
        qrScanButton.layer.cornerRadius = 5
        qrScanButton.backgroundColor = UIColor.whiteSmoke
        
        addressBookButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        addressBookButton.backgroundColor = .clear
        addressBookButton.layer.cornerRadius = 5
        addressBookButton.backgroundColor = UIColor.whiteSmoke
        
        if let qrScanImage = UIImage(named: "qr_code_icon") {
            qrScanButton.setImage(qrScanImage, for: .normal)
        }
        
        if let addressBookImage = UIImage(named: "address_book") {
            addressBookButton.setImage(addressBookImage, for: .normal)
        }
        
        qrScanButton.addTarget(self, action: #selector(scanQr), for: .touchUpInside)
        addressBookButton.addTarget(self, action: #selector(fromAddressBook), for: .touchUpInside)
        
        textView.font = applyFont(ofSize: 16, weight: .regular)
        textView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 191, green: 201, blue: 215)]
        )

        textView.rightView = UIView(frame: CGRect(x: 0, y: 0, width: !hideAddressBookButton ? 80 : 40, height: 0))
        textView.rightViewMode = .always
    }
    
    override func configureConstraints() {
        let border = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1.5))
        
        buttonsView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .width(80)
            .define{ flex in
                flex.addItem(qrScanButton).width(35).height(35)
                
                if !hideAddressBookButton {
                    flex.addItem(addressBookButton).width(35).height(35).marginLeft(5)
                }
        }
        
        rootFlexContainer.flex
            .width(100%)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(textView).width(100%).marginBottom(11)
                flex.addItem(border).width(100%).backgroundColor(UIColor.veryLightBlue)
                
                flex.addItem(buttonsView).position(.absolute).top(-10).right(0)
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
            self?.textView.text = address
        }
        let sendNavigation = UINavigationController(rootViewController: addressBookVC)
        presenter?.present(sendNavigation, animated: true)
    }
    
    private func updateAddress(from uri: QRUri) {
        textView.text = uri.address
    }
}
