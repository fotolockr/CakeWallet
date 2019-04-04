import UIKit

final class BitrefillOrderViewController: BaseViewController<BitrefillOrderView> {
    init(product: BitrefillProduct) {
        super.init()
        contentView.productName.text = product.name
//        contentView.productImage.image = product.icon
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Order"
        contentView.amountTextField.textField.keyboardType = .decimalPad
        contentView.emailTextField.textField.keyboardType = .emailAddress
    }
}
