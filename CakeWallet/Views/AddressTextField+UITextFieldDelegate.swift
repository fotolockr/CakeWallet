import UIKit

extension AddressTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard text != nil && !text!.isEmpty else {
            originText.accept("")
            return
        }
        
        text = originText.value
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = text else {
            originText.accept("")
            return
        }
        
        originText.accept(text)
        change(text: originText.value)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newOriginText = originText.value + string
        originText.accept(newOriginText)
        return true
    }
}
