import UIKit
import FlexLayout

final class NewAddressView: BaseFlexView {
    let cardView: UIView
    let contactNameTextField: UITextField
    
    let addressView: AddressView
    
    let saveButton: UIButton
    let resetButton: UIButton
    let buttonsContainer: UIView
    
    let pickerView: UIPickerView
    let pickerTextField: UITextField
    
    required init() {
        cardView = CardView()
        contactNameTextField = FloatingLabelTextField(placeholder: NSLocalizedString("Contact Name", comment: ""))
        
        addressView = AddressView(withAddressBook: false)
        
        saveButton = PrimaryButton(title: NSLocalizedString("save", comment: ""))
        resetButton = SecondaryButton(title: NSLocalizedString("reset", comment: ""))
        buttonsContainer = UIView()
        
        pickerView = UIPickerView()
        pickerTextField = FloatingLabelTextField(placeholder: NSLocalizedString("Select cryptocurrency", comment: ""))
        pickerTextField.inputView = pickerView
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressView.textView.delegate = self
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).justifyContent(.spaceBetween).define { flex in
            flex.addItem(contactNameTextField).height(50)
            flex.addItem(pickerTextField).height(50).marginTop(10)
            flex.addItem(addressView).marginTop(10)
        }
        
        buttonsContainer.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(resetButton).height(56).width(45%)
            flex.addItem(saveButton).height(56).width(45%)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(buttonsContainer).width(100%).marginTop(20)
        }
    }
}
