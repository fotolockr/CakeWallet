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

final class AddressTextField: UITextField {
    private static let holder = "..."
    var originText: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    func change(text: String?) {
        originText = text
        
        guard let text = text else {
            self.text = nil
            return
        }
        
        let length = numberOfCharactersThatFit(for: text)
        
        guard text.count > length else {
            self.text = text
            return
        }
        
        let middle = length / 2
        let begin = text[0..<middle]
        let end = text.suffix(middle - 1)
        let formattedText = begin + AddressTextField.holder + end
        self.text = formattedText
    }
    
    private func numberOfCharactersThatFit(for text: String?) -> Int {
        let fontRef = CTFontCreateWithName(font!.fontName as CFString, font!.pointSize, nil)
        let attributes = [kCTFontAttributeName : fontRef]
        let attributedString = NSAttributedString(string: text!, attributes: attributes as [NSAttributedStringKey : Any])
        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        var characterFitRange: CFRange = CFRange()
        
        let rightViewWidth = rightView?.frame.size.width ?? 0
        let width = bounds.size.width - rightViewWidth
        let height = bounds.size.height
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSize(width: width, height: height), &characterFitRange)
        return Int(characterFitRange.length)
    }
}

extension AddressTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        text = originText
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        change(text: originText)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        originText = string
        return true
    }
}

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
        
        return QRCodeReaderViewController(builder: builder)
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
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.wildDarkBlue,
                NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: CGFloat(16))!
            ]
        )

        textView.rightView = UIView(frame: CGRect(x: 0, y: 0, width: !hideAddressBookButton ? 80 : 35, height: 0))
        textView.rightViewMode = .always
    }
    
    override func configureConstraints() {
        let border = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1.5))
        
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
            self?.textView.change(text: address)
        }
        let sendNavigation = UINavigationController(rootViewController: addressBookVC)
        presenter?.present(sendNavigation, animated: true)
    }
    
    private func updateAddress(from uri: QRUri) {
        textView.change(text: uri.address)
    }
}
