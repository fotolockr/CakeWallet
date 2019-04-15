import UIKit
import FlexLayout


final class BitrefillOrderView: BaseScrollFlexView {
    let cardView: CardView
    let mainTitleLabel: UILabel
    let secondaryTitleLabel: UILabel
    
    let summaryLabel: UILabel
    let priceLabel: UILabel
    let addressLabel: UILabel
    
    let timerLabel: UILabel
    var timer = Timer()
    var timerIsRunning = false
    
    let qrCodeHolder: UIView
    let qrImage: UIImageView
    
    required init() {
        cardView = CardView()
        mainTitleLabel = UILabel(text: "Payment")
        secondaryTitleLabel = UILabel(text: "Confirm the details below to purchase your refill")
        
        summaryLabel = UILabel()
        priceLabel = UILabel()
        addressLabel = UILabel()
        timerLabel = UILabel(text: "Expiring in")
        
        qrCodeHolder = UIView()
        qrImage = UIImageView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        mainTitleLabel.font = applyFont(ofSize: 26, weight: .bold)
        secondaryTitleLabel.font = applyFont(ofSize: 17, weight: .semibold)
        secondaryTitleLabel.textColor = UIColor.wildDarkBlue
        secondaryTitleLabel.numberOfLines = 2
        
        summaryLabel.font = applyFont(ofSize: 18, weight: .bold)
        priceLabel.font = applyFont(ofSize: 16)
        addressLabel.font = applyFont(ofSize: 16)
        timerLabel.font = applyFont(ofSize: 16)
        timerLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func configureConstraints() {
        qrCodeHolder.flex
            .width(100%)
            .alignItems(.center)
            .define{ flex in
                flex.addItem(qrImage).size(CGSize(width: 150, height: 150)).marginTop(40)
        }
        
        cardView.flex
            .width(90%)
            .padding(30, 25, 35, 25)
            .define{ flex in
                flex.addItem(mainTitleLabel).marginBottom(8)
                flex.addItem(secondaryTitleLabel).marginBottom(32)
                
                flex.addItem(summaryLabel).marginBottom(10)
                flex.addItem(priceLabel).width(100%).marginBottom(10)
                flex.addItem(addressLabel).width(100%).marginBottom(10)
                flex.addItem(timerLabel).width(100%)
                
                flex.addItem(qrCodeHolder)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .padding(25, 0, 25, 0)
            .define { flex in
                flex.addItem(cardView)
        }
    }
}
