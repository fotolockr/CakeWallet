import UIKit
import FlexLayout

final class PickerButtonView: BaseFlexView {
    let pickedCurrency, walletNameLabel: UILabel
    let pickerIcon: UIImageView
    
    required init() {
        pickerIcon = UIImageView(image: UIImage(named: "arrow_bottom_purple_icon"))
        pickedCurrency = UILabel(text: "BTC")
        walletNameLabel = UILabel(text: "Main wallet")
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        pickedCurrency.font = applyFont(ofSize: 26, weight: .bold)
        walletNameLabel.font = applyFont(ofSize: 13)
        walletNameLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .width(100)
            .height(50)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(pickedCurrency)
                flex.addItem(walletNameLabel)
                flex.addItem(pickerIcon).position(.absolute).top(10).right(30)
        }
    }
}

final class ExchangeCardView: BaseFlexView {
    let cardType: ExchangeCardType
    let cardTitle: UILabel
    let topCardView: UIView
    let pickerRow: UIView
    let pickerButton: UIView
    let pickedCurrency: UILabel
    let walletNameLabel: UILabel
    let amountTextField: TextField
    let addressContainer: AddressView
    let pickerIcon: UIImageView
    let receiveView: UIView
    let receiveViewTitle: UILabel
    let receiveViewAmount: UILabel
    
    let pickerButtonView: PickerButtonView
    
    required init(cardType: ExchangeCardType, cardTitle: String) {
        self.cardType = cardType
        self.cardTitle = UILabel(text: cardTitle)
        topCardView = UIView()
        pickerRow = UIView()
        pickerButton = UIView()
        pickedCurrency = UILabel(text: "BTC")
        walletNameLabel = UILabel(text: "Main wallet")
        amountTextField = TextField(placeholder: "0.000", fontSize: 25, withTextAlignmentReverse: true)
        // TODO: coin address
        addressContainer = AddressView(placeholder: cardType == .deposit ? "Refund address" : "Address")
        pickerIcon = UIImageView(image: UIImage(named: "arrow_bottom_purple_icon"))
        receiveView = UIView()
        receiveViewTitle = UILabel(text: "You will receive")
        receiveViewAmount = UILabel(text: "24.092")
        
        pickerButtonView = PickerButtonView()
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        cardTitle.font = applyFont(ofSize: 17, weight: .semibold)
        
        pickedCurrency.font = applyFont(ofSize: 26, weight: .bold)
        walletNameLabel.font = applyFont(ofSize: 13)
        walletNameLabel.textColor = UIColor.wildDarkBlue
        
        amountTextField.textField.keyboardType = .decimalPad
        
        receiveViewTitle.font = applyFont(ofSize: 15)
        receiveViewTitle.textColor = UIColor.wildDarkBlue
        receiveViewTitle.textAlignment = .right
        
        receiveViewAmount.font = applyFont(ofSize: 22, weight: .semibold)
        receiveViewAmount.textColor = UIColor.purpley
        receiveViewAmount.textAlignment = .right
    }
    
    override func configureConstraints() {
        rootFlexContainer.layer.cornerRadius = 12
        rootFlexContainer.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 0, blur: 20, spread: -10)
        rootFlexContainer.backgroundColor = Theme.current.card.background
        
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
                flex.addItem(cardType == .deposit ? amountTextField : receiveView)
                    .width(67%)
                    .paddingBottom(7)
        }
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(18, 15, 35, 15)
            .marginBottom(25)
            .define{ flex in
                flex.addItem(cardTitle).marginBottom(25)
                flex.addItem(topCardView).marginBottom(25)
                flex.addItem(addressContainer).width(100%)
        }
    }
}
