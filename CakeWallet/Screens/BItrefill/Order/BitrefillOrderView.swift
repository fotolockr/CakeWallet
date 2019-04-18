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
    let copyButton: UIButton
    let copyButtonHolder: UIView
    
    required init() {
        cardView = CardView()
        mainTitleLabel = UILabel(text: "Payment")
        secondaryTitleLabel = UILabel(text: "Confirm the details below to purchase your refill")
        
        summaryLabel = UILabel()
        priceLabel = UILabel()
        addressLabel = UILabel()
        timerLabel = UILabel(text: "Expiring in")
        
        qrCodeHolder = UIView()
        copyButtonHolder = UIView()
        qrImage = UIImageView()
    
        copyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 60))
        copyButton.backgroundColor = UIColor.wildDarkBlue
        copyButton.titleLabel?.font = applyFont(ofSize: 16)
        copyButton.layer.cornerRadius = 5
        copyButton.setTitle("Copy address", for: .normal)
        
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
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        timerLabel.font = applyFont(ofSize: 16)
        timerLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func configureConstraints() {
        copyButtonHolder.flex
            .alignItems(.center)
            .define { flex in
                flex.addItem(copyButton).width(55%)
        }
        
        qrCodeHolder.flex
            .width(100%)
            .alignItems(.center)
            .define{ flex in
                flex.addItem(qrImage).size(CGSize(width: 150, height: 150))
        }
        
        cardView.flex
            .width(90%)
            .padding(30, 35, 35, 35)
            .define{ flex in
                flex.addItem(mainTitleLabel).marginBottom(8)
                flex.addItem(secondaryTitleLabel).marginBottom(32)
                
                flex.addItem(summaryLabel).marginBottom(10)
                flex.addItem(priceLabel).width(100%).marginBottom(10)
                flex.addItem(timerLabel).width(100%)
                
                flex.addItem(addressLabel).width(100%).marginTop(30)
                flex.addItem(copyButtonHolder).marginTop(15).width(100%)
                flex.addItem(qrCodeHolder).marginTop(15)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .padding(25, 0, 25, 0)
            .define { flex in
                flex.addItem(cardView)
        }
    }
}
