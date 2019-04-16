import UIKit
import FlexLayout


final class BitrefillMoneroOrderView: BaseScrollFlexView {
    let cardView: CardView
    let mainTitleLabel: UILabel
    let secondaryTitleLabel: UILabel
    

    required init() {
        cardView = CardView()
        mainTitleLabel = UILabel(text: "XMR Payment")
        secondaryTitleLabel = UILabel(text: "Some details below")
    
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        mainTitleLabel.font = applyFont(ofSize: 26, weight: .bold)
        secondaryTitleLabel.font = applyFont(ofSize: 17, weight: .semibold)
        secondaryTitleLabel.textColor = UIColor.wildDarkBlue
        secondaryTitleLabel.numberOfLines = 2
    }
    
    override func configureConstraints() {
        cardView.flex
            .width(90%)
            .padding(30, 35, 35, 35)
            .define{ flex in
                flex.addItem(mainTitleLabel).marginBottom(8)
                flex.addItem(secondaryTitleLabel).marginBottom(32)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .padding(25, 0, 25, 0)
            .define { flex in
                flex.addItem(cardView)
        }
    }
}

