import UIKit
import FlexLayout

final class ExchangeResultView: BaseScrollFlexView {
    let idLabel: UILabel
//    let minAmountLabel: UILabel
    //    let maxAmountLabel: UILabel
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
    
    required init() {
        idLabel = UILabel(fontSize: 14)
        amountLabel = UILabel(fontSize: 14)
//        minAmountLabel = UILabel(fontSize: 14)
//        maxAmountLabel = UILabel(fontSize: 14)
        addressLabel = UILabel(fontSize: 14)
        statusLabel = UILabel(fontSize: 14)
        qrImageView = UIImageView(image: nil)
        copyAddressButton = CopyButton(title: NSLocalizedString("copy_address", comment: ""))
        copyIdButton = CopyButton(title: NSLocalizedString("copy_id", comment: ""))
        confirmButton = PrimaryButton(title: NSLocalizedString("confirm", comment: ""))
        resultDescriptionLabel = UILabel(fontSize: 14)
        descriptionTextView = UITextView(frame: .zero)
        cardView = CardView()
        topRow = UIView()
        infoColumn = UIView()
        copyButtonsRow = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        idLabel.numberOfLines = 0
        idLabel.textColor = .spaceViolet
        amountLabel.numberOfLines = 0
        amountLabel.textColor = .spaceViolet
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        copyAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        copyIdButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        descriptionTextView.textColor = .wildDarkBlue
        descriptionTextView.font = UIFont.systemFont(ofSize: 11)
        descriptionTextView.isEditable = false
        resultDescriptionLabel.numberOfLines = 0
    }
    
    override func configureConstraints() {
        infoColumn.flex.justifyContent(.center).define({ flex in
            flex.addItem(idLabel).height(15).width(100%)
            flex.addItem(amountLabel).height(15).width(100%)
            flex.addItem(statusLabel).height(15).width(100%)
        })
        
        topRow.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(infoColumn).grow(1).height(100%)
            flex.addItem(qrImageView).height(111).width(111)
        }
        
        copyButtonsRow.flex.direction(.row).justifyContent(.spaceBetween).marginTop(20).define({ flex in
            flex.addItem(copyAddressButton).height(56).width(45%)
            flex.addItem(copyIdButton).height(56).width(45%)
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
