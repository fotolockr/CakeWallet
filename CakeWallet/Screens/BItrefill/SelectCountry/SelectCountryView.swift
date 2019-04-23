import UIKit
import FlexLayout


final class BitrefillSelectCountryView: BaseScrollFlexViewWithBottomSection {
    let welcomeLabel = UILabel(text: "Welcome to Bitrefill in Cake Wallet")
    let descriptionLabel = UILabel(text: "Plese select your country to start using Bitrefill service")
    
    let pickerView = UIPickerView()
    let countryTextFieldHolder = UIView()
    let countryTextField = TextField(placeholder: "Select country", fontSize: 20, isTransparent: false)
    
    let doneButton = PrimaryLoadingButton()
    
    required init() {
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    
        welcomeLabel.font = applyFont(ofSize: 26, weight: .bold)
        welcomeLabel.numberOfLines = 2
        welcomeLabel.textAlignment = .center
        
        descriptionLabel.font = applyFont(ofSize: 17)
        descriptionLabel.textColor = UIColor.wildDarkBlue
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        
        countryTextField.textField.text = BitrefillCountry.us.fullCountryName()
        countryTextField.textField.inputView = pickerView
        countryTextField.borderView.isHidden = true
        
        doneButton.setTitle("Continue", for: .normal)
    }
    
    override func configureConstraints() {
        countryTextFieldHolder.layer.cornerRadius = 10
        
        countryTextFieldHolder.flex
            .alignItems(.center)
            .width(100%).height(55).paddingTop(15).marginTop(15)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(countryTextField).width(90%)
        }
        
        rootFlexContainer.flex
            .alignItems(.center)
            .width(100%).height(100%).padding(30)
            .backgroundColor(.clear)
            .define { flex in
                flex.addItem(welcomeLabel).marginBottom(50)
                flex.addItem(descriptionLabel)
                flex.addItem(countryTextFieldHolder).width(100%)
        }
        
        bottomSectionView.flex
            .alignItems(.center)
            .define { flex in
                flex.addItem(doneButton).width(85%).height(56)
        }
    }
}

