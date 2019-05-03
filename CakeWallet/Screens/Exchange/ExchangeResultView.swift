import UIKit
import FlexLayout

class CopyableLabel: UILabel {
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showCopyMenu(sender:))
        ))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc
    func showCopyMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
}

final class ExchangeResultView: BaseScrollFlexView {
    let idLabel: UILabel
    let amountLabel: UILabel
    let addressLabel: UILabel
    let qrImageView: UIImageView
    let copyAddressButton: CopyButton
    let copyIdButton: CopyButton
    let confirmButton: UIButton
    let resultDescriptionLabel: UILabel
    let descriptionTextView: UITextView
    let cardView: UIView
    let topRow: UIView
    let infoColumn: UIView
    let copyButtonsRow: UIView
    let statusLabel: UILabel
    let paymentIDRow: UIView
    let paymentIDTitle: UILabel
    let paymentIDLabel: UILabel
    let btcTxIDLabel: UILabel
    let btcTxIDRow: UILabel
    let btcTxIDTextLabel: CopyableLabel
    let timeoutLabel: UILabel
    
    required init() {
        idLabel = UILabel()
        amountLabel = UILabel()
        addressLabel = UILabel()
        statusLabel = UILabel()
        qrImageView = UIImageView(image: nil)
        copyAddressButton = CopyButton(title: NSLocalizedString("copy_address", comment: ""))
        copyIdButton = CopyButton(title: NSLocalizedString("copy_id", comment: ""))
        confirmButton = PrimaryButton(title: NSLocalizedString("confirm", comment: ""))
        resultDescriptionLabel = UILabel(fontSize: 14)
        descriptionTextView = UITextView(frame: .zero)
        cardView = UIView()
        topRow = UIView()
        infoColumn = UIView()
        copyButtonsRow = UIView()
        paymentIDRow = UIView()
        paymentIDTitle = UILabel(fontSize: 14)
        paymentIDLabel = CopyableLabel(fontSize: 14)
        btcTxIDLabel = UILabel(fontSize: 14)
        btcTxIDRow = UILabel(fontSize: 14)
        btcTxIDTextLabel = CopyableLabel(fontSize: 14)
        timeoutLabel = UILabel(fontSize: 14)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        idLabel.numberOfLines = 0
        idLabel.textColor = .spaceViolet
        
        idLabel.font = applyFont(ofSize: 15)
        amountLabel.font = applyFont(ofSize: 15)
        addressLabel.font = applyFont(ofSize: 15)
        statusLabel.font = applyFont(ofSize: 15)
        timeoutLabel.font = applyFont(ofSize: 15)
        
        amountLabel.numberOfLines = 0
        amountLabel.textColor = .spaceViolet
        
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.font = applyFont(ofSize: 13)
        addressLabel.textColor = .purpley
        
        copyAddressButton.titleLabel?.font = applyFont(ofSize: 13)
        copyIdButton.titleLabel?.font = applyFont(ofSize: 13)
        descriptionTextView.textColor = .wildDarkBlue
        descriptionTextView.font = applyFont(ofSize: 12)
        descriptionTextView.isEditable = false
        
        resultDescriptionLabel.numberOfLines = 0
        resultDescriptionLabel.font = applyFont(ofSize: 14)
        resultDescriptionLabel.textColor = .grayBlue
        
        btcTxIDLabel.numberOfLines = 0
        btcTxIDRow.isUserInteractionEnabled = true
        btcTxIDTextLabel.font = applyFont(ofSize: 14)
        btcTxIDTextLabel.numberOfLines = 0
        paymentIDLabel.numberOfLines =  0
    }
    
    override func configureConstraints() {
        let isSmallScreen = UIScreen.main.bounds.width < 414
        
        paymentIDRow.flex.direction(.row).define { flex in
            flex.addItem(paymentIDTitle).height(25)
            flex.addItem(paymentIDLabel).grow(1)
        }
        
        btcTxIDRow.flex.direction(.column).define { flex in
            flex.addItem(btcTxIDLabel).height(25)
            flex.addItem(btcTxIDTextLabel).grow(1)
        }
        
        infoColumn.flex.justifyContent(.center).define({ flex in
            flex.addItem(idLabel).height(28).width(100%)
            flex.addItem(amountLabel).height(28).width(100%)
            flex.addItem(paymentIDRow).height(28).width(100%)
            flex.addItem(statusLabel).height(28).width(100%)
            flex.addItem(timeoutLabel).height(28).width(100%)
            flex.addItem(btcTxIDRow).width(100%)
        })
        
        topRow.flex
            .direction(isSmallScreen ? .column : .row)
            .justifyContent(isSmallScreen ? .center : .spaceBetween)
            .alignItems(isSmallScreen ? .center : .stretch)
            .define { flex in
                let infoColumnFlex = flex.addItem(infoColumn)
                flex.addItem(qrImageView).height(111).width(111)
                
                if !isSmallScreen {
                    infoColumnFlex.height(100%)
                } else {
                    infoColumnFlex.width(100%)
                }
        }
        
        copyButtonsRow.flex
            .direction(.row)
            .justifyContent(.center)
            .marginTop(20)
            .define({ flex in
                flex.addItem(copyAddressButton).height(40).width(46%).marginRight(10)
                flex.addItem(copyIdButton).height(40).width(46%).marginLeft(10)
        })
        
        cardView.flex.padding(20).define { flex in
            flex.addItem(topRow)
            flex.addItem(addressLabel).marginTop(20)
            flex.addItem(copyButtonsRow)
            flex.addItem(resultDescriptionLabel).grow(1).marginTop(20).width(100%) //.height(50)
            flex.addItem(descriptionTextView).grow(1) //.marginTop(20)
        }
        
        rootFlexContainer.flex.padding(20).define { flex in
            flex.addItem(cardView)
            flex.addItem(confirmButton).height(56).marginTop(10)
        }
    }
}
