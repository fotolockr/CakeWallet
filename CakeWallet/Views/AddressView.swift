import UIKit
import FlexLayout
import QRCodeReader

final class AddressView: BaseFlexView {
    let textView: AddressTextField
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
        
        let QRCodeReaderVC = QRCodeReaderViewController(builder: builder)
        QRCodeReaderVC.completionBlock = { [weak self] result in
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
                this.updateResponsible?.updated(this, withURI: uri)
            }
            
            this.QRReaderVC.stopScanning()
            this.QRReaderVC.dismiss(animated: true)
        }
        
        return QRCodeReaderVC
    }()
    
    required init(placeholder: String = "", hideAddressBookButton: Bool = false) {
        self.placeholder = placeholder
        self.hideAddressBookButton = hideAddressBookButton
        textView = AddressTextField()
        borderView = UIView()
        buttonsView = UIView()
        qrScanButton = UIButton()
        addressBookButton = UIButton()
        
        super.init()
    }
    
    required init() {
        self.placeholder = ""
        self.hideAddressBookButton = false
        textView = AddressTextField()
        borderView = UIView()
        buttonsView = UIView()
        qrScanButton = UIButton()
        addressBookButton = UIButton()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        qrScanButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        qrScanButton.backgroundColor = .clear
        qrScanButton.layer.cornerRadius = 5
        qrScanButton.backgroundColor = UIColor.whiteSmoke
        
        addressBookButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
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
        
        textView.font = applyFont(ofSize: 15, weight: .regular)
        textView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.wildDarkBlue,
                NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: CGFloat(15))!
            ]
        )

        textView.rightView = UIView(frame: CGRect(x: 0, y: 0, width: !hideAddressBookButton ? 80 : 35, height: 0))
        textView.rightViewMode = .always
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.change(text: textView.originText.value)
    }
    
    override func configureConstraints() {        
        buttonsView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .width(!hideAddressBookButton ? 80 : 35)
            .define{ flex in
                flex.addItem(qrScanButton).width(35).height(35)
                
                if !hideAddressBookButton {
                    flex.addItem(addressBookButton).width(35).height(35).marginLeft(5)
                }
        }
        
        rootFlexContainer.flex
            .width(100%)
            .backgroundColor(.clear)
            .define{ flex in
                flex.addItem(textView).backgroundColor(.clear).width(100%).marginBottom(11)
                flex.addItem(borderView).height(1.5).width(100%).backgroundColor(UIColor.veryLightBlue)
                
                flex.addItem(buttonsView).position(.absolute).top(-10).right(0)
        }
    }
    
    @objc
    private func scanQr() {
        QRReaderVC.modalPresentationStyle = .overFullScreen
        presenter?.parent?.present(QRReaderVC, animated: true)
    }
    
    @objc
    private func fromAddressBook() {
        let addressBookVC = AddressBookViewController(addressBook: AddressBook.shared, store: store, isReadOnly: true)
        addressBookVC.doneHandler = { [weak self] address in
            self?.textView.change(text: address)
        }
        let sendNavigation = UINavigationController(rootViewController: addressBookVC)
        presenter?.present(sendNavigation, animated: true)
    }
    
    private func updateAddress(from uri: QRUri) {
        textView.change(text: uri.address)
    }
}
