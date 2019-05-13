import UIKit
import FlexLayout

final class RecoverFromKeysView: BaseFlexView {
    let cardWrapper, actionButtonsContainer: UIView
    let restoreFromHeightView: RestoreFromHeightView
    var walletNameField, viewKeyField, spendKeyField: CWTextField
    var addressTextView: CWTextView
    let doneButton: LoadingButton
    
    required init() {
        cardWrapper = UIView()
        actionButtonsContainer = UIView()
        walletNameField = CWTextField(placeholder: NSLocalizedString("wallet_name", comment: ""), fontSize: 16)
        addressTextView = CWTextView(placeholder: NSLocalizedString("address", comment: ""), fontSize: 16)
        viewKeyField = CWTextField(placeholder: NSLocalizedString("view_key_(private)", comment: ""), fontSize: 16)
        spendKeyField = CWTextField(placeholder: NSLocalizedString("spend_key_(private)", comment: ""), fontSize: 16)
        restoreFromHeightView = RestoreFromHeightView()

        doneButton = PrimaryLoadingButton()
        doneButton.setTitle(NSLocalizedString("recover", comment: ""), for: .normal)
        
        super.init()
        addressTextView.delegate = self
    }
    
    override func configureConstraints() {
        var adaptiveMargin: CGFloat
        cardWrapper.layer.cornerRadius = 12
        cardWrapper.backgroundColor = Theme.current.card.background
        
        adaptiveMargin = adaptiveLayout.getSize(forLarge: 34, forBig: 32, defaultSize: 30)
        
        if adaptiveLayout.screenType == .iPhones_5_5s_5c_SE {
           adaptiveMargin = 18
        }
        
        cardWrapper.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(30, 10, 10, 10)
            .define{ flex in
                flex.addItem(walletNameField).width(100%).marginBottom(adaptiveMargin)
                flex.addItem(addressTextView).width(100%).marginBottom(adaptiveMargin)
                flex.addItem(viewKeyField).width(100%).marginBottom(adaptiveMargin)
                flex.addItem(spendKeyField).width(100%).marginBottom(adaptiveMargin)
                flex.addItem(restoreFromHeightView).width(100%).marginBottom(adaptiveMargin)
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
