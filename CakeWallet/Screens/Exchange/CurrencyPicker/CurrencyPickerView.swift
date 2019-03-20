import UIKit
import FlexLayout
import VisualEffectView

final class CurrencyPickerTableCell: FlexCell {
    let cryptoLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cryptoLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        cryptoLabel.textAlignment = .center
        cryptoLabel.font = applyFont(ofSize: 17, weight: .semibold)
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        contentView.flex
            .paddingLeft(18)
            .paddingTop(20)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(cryptoLabel).width(100%)
        }
    }
    
    func configure(crypto: String, isSelected: Bool) {
        cryptoLabel.text = crypto
        cryptoLabel.textColor = isSelected ? UIColor(red: 138, green: 80, blue: 255) : .black
        contentView.flex.layout()
    }
}

final class CurrencyPickerView: BaseFlexView {
    var pickerHolderView: UIView
    let picker: UITableView
    let pickerTitle: UILabel
    var backgroundBlurView: UIView
    
    static let screenWidth = adaptiveLayout.getScreenBounds().screenWidth
    static let screenHeight = adaptiveLayout.getScreenBounds().screenHeight
    
    required init() {
        pickerHolderView = UIView()
        picker = UITableView()
        pickerTitle = UILabel(text: "Change Currency")
        backgroundBlurView = UIView(frame: CGRect(x: 0, y: 0, width: CurrencyPickerView.screenWidth, height: CurrencyPickerView.screenHeight))
        backgroundBlurView.isUserInteractionEnabled = true
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        isOpaque = false
        backgroundColor = .clear
        pickerTitle.font = applyFont(ofSize: 16, weight: .bold)
        pickerHolderView.layer.cornerRadius = 18
        pickerHolderView.layer.applySketchShadow(color: UIColor(red: 41, green: 23, blue: 77), alpha: 0.34, x: 0, y: 16, blur: 46, spread: -5)
        picker.layer.cornerRadius = 18
        picker.showsVerticalScrollIndicator = false
    }
    
    override func configureConstraints() {
        let visualEffectView = VisualEffectView(frame: CGRect(x: 0, y: 0, width: CurrencyPickerView.screenWidth, height: CurrencyPickerView.screenHeight))
        visualEffectView.colorTint = UIColor(red: 211, green: 219, blue: 231)
        visualEffectView.colorTintAlpha = 0.65
        visualEffectView.blurRadius = 3
        visualEffectView.scale = 1
        
        backgroundBlurView.addSubview(visualEffectView)
        
        pickerHolderView.flex
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(picker)
        }
        
        rootFlexContainer.flex
            .justifyContent(.end)
            .alignItems(.center)
            .shrink(1)
            .backgroundColor(.clear)
            .padding(50, 25, 25, 25)
            .define{ flex in
                flex.addItem(backgroundBlurView).position(.absolute).top(0).left(0)
                flex.addItem(pickerTitle).marginBottom(18)
                flex.addItem(pickerHolderView).paddingTop(15).paddingRight(18)
        }
    }
}

