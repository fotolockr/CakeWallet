import UIKit
import FlexLayout

final class RecoverFromSeedView: BaseFlexView {
    let cardWrapper, actionButtonsContainer: UIView
    let restoreFromHeightView: RestoreFromHeightView
    var walletNameField: TextField
    var seedField: TextView
    let doneButton: LoadingButton
    
    required init() {
        cardWrapper = UIView()
        actionButtonsContainer = UIView()
        walletNameField = TextField(placeholder: NSLocalizedString("wallet_name", comment: ""), fontSize: 16, isTransparent: false)
        restoreFromHeightView = RestoreFromHeightView()
        seedField = TextView(placeholder: NSLocalizedString("seed", comment: ""), fontSize: 16)
        doneButton = PrimaryLoadingButton(type: .custom)
        doneButton.setTitle(NSLocalizedString("recover", comment: ""), for: .normal)
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        seedField.textField.isScrollEnabled = false
        seedField.textField.delegate = self
    }
    
    override func configureConstraints() {
        var adaptiveMargin: CGFloat
        cardWrapper.layer.cornerRadius = 12
        cardWrapper.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 0, blur: 20, spread: -10)
        cardWrapper.backgroundColor = Theme.current.card.background
        
        adaptiveMargin = adaptiveLayout.getSize(forLarge: 34, forBig: 32, defaultSize: 30)
        
        if adaptiveLayout.screenType == .iPhones_5_5s_5c_SE {
            adaptiveMargin = 18
        }
        
        cardWrapper.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(40, 20, 45, 20)
            .define{ flex in
                flex.addItem(walletNameField).width(100%).marginBottom(adaptiveMargin)
                flex.addItem(restoreFromHeightView).width(100%).marginBottom(adaptiveMargin - 10)
                flex.addItem(seedField).width(100%)
        }
        
        actionButtonsContainer.flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(doneButton).height(56).width(100%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(20)
            .define { flex in
                flex.addItem(cardWrapper).width(100%)
                flex.addItem(actionButtonsContainer).width(100%)
        }
    }
}
