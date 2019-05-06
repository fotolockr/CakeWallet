import UIKit
import FlexLayout

final class NewNodeView: BaseFlexView {
    let cardView: UIView
    let nodeAddressTextField: TextField
    let nodePortTextField: TextField
    let loginTextField: TextField
    let passwordTextField: TextField
    let saveButton: UIButton
    let resetSettings: UIButton
    let buttonsContainer: UIView
    
    required init() {
        cardView = UIView()
        nodeAddressTextField = TextField(placeholder: NSLocalizedString("node_address", comment: ""))
        nodePortTextField = TextField(placeholder: NSLocalizedString("node_port", comment: ""))
        loginTextField = TextField(placeholder: NSLocalizedString("login", comment: ""))
        passwordTextField = TextField(placeholder: NSLocalizedString("password", comment: ""))
        saveButton = PrimaryButton(title: NSLocalizedString("save", comment: ""))
        resetSettings = SecondaryButton(title: NSLocalizedString("reset", comment: ""))
        buttonsContainer = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nodePortTextField.textField.keyboardType = .numberPad
        passwordTextField.textField.isSecureTextEntry = true
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20, 10, 20, 10).justifyContent(.spaceBetween).define { flex in
            flex.addItem(nodeAddressTextField).height(50).marginTop(10)
            flex.addItem(nodePortTextField).height(50).marginTop(10)
            flex.addItem(loginTextField).height(50).marginTop(10)
            flex.addItem(passwordTextField).height(50).marginTop(10)
        }
        
        buttonsContainer.flex.direction(.row).justifyContent(.center).define { flex in
            flex.addItem(resetSettings).height(56).width(45%).marginRight(10)
            flex.addItem(saveButton).height(56).width(45%).marginLeft(10)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(buttonsContainer).width(100%).marginTop(20)
        }
    }
}
