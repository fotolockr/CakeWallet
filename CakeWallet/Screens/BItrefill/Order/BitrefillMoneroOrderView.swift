import UIKit
import FlexLayout


final class BitrefillMoneroOrderView: BaseScrollFlexViewWithBottomSection {
    let cardView: CardView
    let summaryLabel: UILabel
    let mainTitleLabel: UILabel
    let statusLabel: UILabel
    let confirmButton: PrimaryLoadingButton
    let descriptionTitleLabel: UILabel
    let copyButton: UIButton
    let copyButtonHolder: UIView

    required init() {
        cardView = CardView()
        mainTitleLabel = UILabel(text: "XMR Payment")
        summaryLabel = UILabel()
        descriptionTitleLabel = UILabel()
        statusLabel = UILabel(text: "Status: waiting for confirmation")
        confirmButton = PrimaryLoadingButton()
        copyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 60))
        copyButtonHolder = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        mainTitleLabel.font = applyFont(ofSize: 26, weight: .bold)
        summaryLabel.font = applyFont(ofSize: 17, weight: .semibold)
        summaryLabel.textColor = UIColor.wildDarkBlue
        summaryLabel.numberOfLines = 0
        descriptionTitleLabel.font = applyFont(ofSize: 16)
        descriptionTitleLabel.textColor = UIColor.wildDarkBlue
        descriptionTitleLabel.numberOfLines = 0
        statusLabel.font = applyFont(ofSize: 17)
        statusLabel.numberOfLines = 0
        confirmButton.setTitle("Сonfirm", for: .normal)
        
        copyButton.backgroundColor = UIColor.wildDarkBlue
        copyButton.titleLabel?.font = applyFont(ofSize: 16)
        copyButton.layer.cornerRadius = 5
        copyButton.setTitle("Copy voucher code", for: .normal)
    }
    
    override func configureConstraints() {
        copyButtonHolder.flex
            .alignItems(.center)
            .define { flex in
                flex.addItem(copyButton).width(100%)
        }
        
        cardView.flex
            .width(90%)
            .padding(30, 25, 5, 25)
            .define{ flex in
                flex.addItem(mainTitleLabel).marginBottom(8)
                flex.addItem(summaryLabel).marginBottom(30)
                flex.addItem(descriptionTitleLabel).marginBottom(32)
                flex.addItem(statusLabel).marginBottom(32)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .padding(25, 0, 25, 0)
            .define { flex in
                flex.addItem(cardView)
        }
        
        bottomSectionView.flex
            .padding(0, 20, 0, 20)
            .alignItems(.center)
            .define { flex in
                flex.addItem(confirmButton).width(100%).height(56)
        }
    }
}

