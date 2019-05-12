import UIKit
import FlexLayout

final class NewAddressView: BaseFlexView {
    let cardView: UIView
    let contactNameTextField: CWTextField
    
    let addressView: AddressView
    
    let saveButton: UIButton
    let resetButton: UIButton
    let buttonsContainer: UIView
    
    let pickerView: UIPickerView
    let pickerTextField: CWTextField
    
    required init() {
        cardView = UIView()
        contactNameTextField = CWTextField(placeholder: NSLocalizedString(NSLocalizedString("contact_name", comment: ""), comment: ""))
        contactNameTextField.font = applyFont(ofSize: 15)
        
        addressView = AddressView(placeholder: NSLocalizedString("address", comment: ""), hideAddressBookButton: true)
        addressView.textView.font = applyFont(ofSize: 16)
        
        saveButton = PrimaryButton(title: NSLocalizedString("save", comment: ""))
        resetButton = SecondaryButton(title: NSLocalizedString("reset", comment: ""))
        buttonsContainer = UIView()
        
        pickerView = UIPickerView()
        pickerTextField = CWTextField(placeholder: NSLocalizedString("Select cryptocurrency", comment: ""))
        pickerTextField.inputView = pickerView
        
        super.init()
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20, 15, 20, 15).justifyContent(.spaceBetween).define { flex in
            flex.addItem(contactNameTextField).height(50)
            flex.addItem(pickerTextField).height(50).marginTop(15)
            flex.addItem(addressView).marginTop(30)
        }
        
        buttonsContainer.flex.direction(.row).justifyContent(.center).define { flex in
            flex.addItem(resetButton).height(56).width(45%).marginRight(10)
            flex.addItem(saveButton).height(56).width(45%).marginLeft(10)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).paddingHorizontal(10).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(buttonsContainer).width(100%).marginTop(25).paddingHorizontal(15)
        }
    }
}
