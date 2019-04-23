import UIKit
import FlexLayout

final class RecoverCardView: BaseFlexView {
    var walletNameField, restoreHeightField, restoreDateField: TextField
    var seedView: AddressView
    
    required init() {
        walletNameField = TextField(placeholder: NSLocalizedString("wallet_name", comment: ""), fontSize: 16, isTransparent: false)
        restoreHeightField = TextField(fontSize: 16, isTransparent: false)
        restoreDateField = TextField(fontSize: 16, isTransparent: false)
        seedView = AddressView(hideAddressBookButton: true)
        
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.layer.cornerRadius = 12
        rootFlexContainer.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 0, blur: 20, spread: -10)
        rootFlexContainer.backgroundColor = Theme.current.card.background
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(30, 20, 40, 20)
            .define{ flex in
                flex.addItem(walletNameField).width(100%).marginBottom(25)
                flex.addItem(restoreHeightField).width(100%).marginBottom(25)
                flex.addItem(restoreDateField).width(100%).marginBottom(25)
                flex.addItem(seedView).width(100%)
        }
    }
}
