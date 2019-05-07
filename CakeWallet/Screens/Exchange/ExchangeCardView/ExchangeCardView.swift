import UIKit
import FlexLayout

final class PickerButtonView: BaseFlexView {
    let pickedCurrency, walletNameLabel: UILabel
    let pickerIcon: UIImageView
    
    required init() {
        pickerIcon = UIImageView(image: UIImage(named: "arrow_bottom_purple_icon"))
        pickedCurrency = UILabel(text: "")
        walletNameLabel = UILabel(text: "")
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        pickedCurrency.font = applyFont(ofSize: 26, weight: .bold)
        walletNameLabel.font = applyFont(ofSize: 13)
        walletNameLabel.textColor = UIColor.wildDarkBlue
        backgroundColor = .clear
    }
    
    override func configureConstraints() {
        let currencyWithArrowHolder = UIView()
        
        currencyWithArrowHolder.flex
            .direction(.row)
            .alignItems(.center)
            .define{ flex in
                flex.addItem(pickedCurrency).width(65)
                flex.addItem(pickerIcon)
        }
        
        rootFlexContainer.flex
            .backgroundColor(.clear)
            .define{ flex in
                flex.addItem(currencyWithArrowHolder)
                flex.addItem(walletNameLabel).height(20).width(100%)
        }
    }
}

final class ExchangeCardView: BaseFlexView {
    let cardType: ExchangeCardType
    let cardTitle: UILabel
    let topCardView: UIView
    let pickerRow: UIView
    let pickerButton: UIView
    let amountTextField: CWTextField
    let addressContainer: AddressView
    let receiveView: UIView
    let receiveViewTitle: UILabel
    let receiveViewAmount: UILabel
    let pickerButtonView: PickerButtonView
    let limitsRow: UIView
    let maxLabel: UILabel
    let minLabel: UILabel
    
    required init(cardType: ExchangeCardType, cardTitle: String, addressPlaceholder: String) {
        self.cardType = cardType
        self.cardTitle = UILabel(text: cardTitle)
        topCardView = UIView()
        pickerRow = UIView()
        pickerButton = UIView()
        amountTextField = CWTextField(placeholder: "0.000", fontSize: 25)
        addressContainer = AddressView(placeholder: addressPlaceholder)
        receiveView = UIView()
        receiveViewTitle = UILabel(text: "You will receive")
        receiveViewAmount = UILabel(text: "")
        pickerButtonView = PickerButtonView()
        limitsRow = UIView()
        maxLabel = UILabel(fontSize: 10)
        minLabel = UILabel(fontSize: 10)
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        cardTitle.font = applyFont(ofSize: 17, weight: .semibold)
        amountTextField.textAlignment = .right
        amountTextField.keyboardType = .decimalPad
        receiveViewTitle.font = applyFont(ofSize: 15)
        receiveViewTitle.textColor = UIColor.wildDarkBlue
        receiveViewTitle.textAlignment = .right
        receiveViewAmount.font = applyFont(ofSize: 22, weight: .semibold)
        receiveViewAmount.textColor = UIColor.purpley
        receiveViewAmount.textAlignment = .right
        maxLabel.textColor = .wildDarkBlue
        maxLabel.textAlignment = .right
        minLabel.textColor = .wildDarkBlue
        minLabel.textAlignment = .right
        backgroundColor = .clear
        rootFlexContainer.layer.cornerRadius = 12
    }
    
    override func configureConstraints() {
        limitsRow.flex.direction(.row).define { flex in
            flex.addItem(minLabel).width(50%)
            flex.addItem(maxLabel).width(50%)
        }
        
        receiveView.flex
            .alignItems(.end)
            .define{ flex in
                flex.addItem(receiveViewTitle)
                flex.addItem(receiveViewAmount).width(100%)
        }
        
        topCardView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.end)
            .width(100%)
            .define{ flex in
                flex.addItem(pickerButtonView)
                flex.addItem(UIView())
                    .width(67%)
                    .paddingBottom(7)
                    .define({ flex in
                        flex.addItem(cardType == .deposit ? amountTextField : receiveView)
                        flex.addItem(limitsRow).height(20).width(100%)
                })
        }
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(18, 15, 35, 15)
            .backgroundColor(UIColor(hex: 0xF9FAFD))
            .define{ flex in
                flex.addItem(cardTitle).marginBottom(25)
                flex.addItem(topCardView).marginBottom(25)
                flex.addItem(addressContainer).width(100%)
        }
    }
}
