import UIKit

final class BitrefillOrderViewController: BaseViewController<BitrefillOrderView> {
    init(product: BitrefillTableItem) {
        super.init()
        contentView.productName.text = product.title
        contentView.productImage.image = product.icon
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Order"
        contentView.amountTextField.textField.keyboardType = .decimalPad
        contentView.emailTextField.textField.keyboardType = .emailAddress
    }
}
