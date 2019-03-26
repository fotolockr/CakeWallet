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
    let backgroundView: UIView
    
    required init() {
        pickerHolderView = UIView()
        picker = UITableView()
        pickerTitle = UILabel(text: "Change Currency")
        backgroundView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        pickerTitle.font = applyFont(ofSize: 16, weight: .bold)
        pickerHolderView.layer.cornerRadius = 18
        pickerHolderView.layer.applySketchShadow(color: UIColor(red: 41, green: 23, blue: 77), alpha: 0.34, x: 0, y: 16, blur: 46, spread: -5)
        picker.layer.cornerRadius = 18
        picker.showsVerticalScrollIndicator = false
        backgroundView.isUserInteractionEnabled = true
    }
    
    override func configureConstraints() {
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
                flex.addItem(backgroundView).backgroundColor(.clear).position(.absolute).left(0).top(0).size(frame.size)
                flex.addItem(pickerTitle).marginBottom(18)
                flex.addItem(pickerHolderView).paddingTop(15).paddingRight(18)
        }
    }
}

