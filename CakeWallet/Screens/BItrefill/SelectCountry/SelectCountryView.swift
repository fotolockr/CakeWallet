import UIKit
import FlexLayout


final class BitrefillSelectCountryView: BaseFlexView {
    let welcomeLabel = UILabel(text: "Welcome to Bitrefill in Cake Wallet")
    let descriptionLabel = UILabel(text: "Plese select your country to start using Bitrefill service")
    
    let pickerView = UIPickerView()
    let textFieldHolder = UIView()
    let textFieldView = TextField(placeholder: "Select country", fontSize: 18, isTransparent: false)
    
    required init() {
        
 
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        welcomeLabel.font = applyFont(ofSize: 22, weight: .bold)
        welcomeLabel.numberOfLines = 2
        welcomeLabel.textAlignment = .center
        
        descriptionLabel.font = applyFont(ofSize: 16)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        
        textFieldView.textField.inputView = pickerView
        textFieldView.borderView.isHidden = true
    }
    
    override func configureConstraints() {
        textFieldHolder.layer.cornerRadius = 10
//        textFieldHolder.layer.borderWidth = 1
        
        textFieldHolder.flex
            .alignItems(.center)
            .width(100%).height(65).paddingTop(15).marginTop(50)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(textFieldView).width(90%)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .width(100%).height(100%).padding(30)
            .backgroundColor(.clear)
            .define { flex in
                flex.addItem(welcomeLabel).marginBottom(10)
                flex.addItem(descriptionLabel)
                flex.addItem(textFieldHolder).width(100%)
//                flex.addItem(picker.textFieldView).width(100).height(40).marginTop(25)
        }
    }
}

