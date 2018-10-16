import UIKit
import FlexLayout

final class SeedView: BaseFlexView {
    let cardView: CardView
    let dateLabel: UILabel
    let seedLabel: UILabel
    let saveButton: UIButton
    let copyButton: UIButton
    let buttonsRowContainer: UIView
    let desciptionLabel: UILabel
    let titleLabel: UILabel
    let separatorView: UIView
    
    required init() {
        cardView = CardView()
        dateLabel = UILabel(fontSize: 16)
        seedLabel = UILabel(fontSize: 14)
        saveButton = SecondaryButton(title: NSLocalizedString("save", comment: ""))
        copyButton = PrimaryButton(title: NSLocalizedString("copy", comment: ""))
        buttonsRowContainer = UIView()
        desciptionLabel = UILabel.withLightText(fontSize: 14)
        titleLabel = UILabel(fontSize: 14)
        separatorView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        desciptionLabel.textAlignment = .center
        dateLabel.textAlignment = .center
        seedLabel.textAlignment = .center
        seedLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
    }
    
    override func configureConstraints() {
        cardView.flex.alignItems(.center).padding(20).define { flex in
            flex.addItem(titleLabel).height(35).width(100%)
            flex.addItem(separatorView)
                .height(1).width(100%)
                .margin(UIEdgeInsets(top: 0, left: -20, bottom: 0, right: -20))
                .backgroundColor(UIColor.init(red: 224, green: 233, blue: 246))
            flex.addItem(dateLabel).width(100%)
            flex.addItem(seedLabel).width(100%).margin(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
        }
        
        buttonsRowContainer.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(saveButton).height(56).width(45%)
            flex.addItem(copyButton).height(56).width(45%)
        }

        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(cardView).width(80%)
            flex.addItem(desciptionLabel).width(80%).marginTop(20)
            flex.addItem(buttonsRowContainer).width(80%).marginTop(20)
        }
    }
}
