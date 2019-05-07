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
        guard text != nil && !text!.isEmpty else {
            originText.accept("")
            return
        }
        
        change(text: originText.value)
    }
    
    func CWTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        originText.accept(string)
        return true
    }
}
