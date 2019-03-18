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
        
        cryptoLabel.font = applyFont(ofSize: 17, weight: .semibold)
    }
    
    override func configureConstraints() {
        contentView.flex
//            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
//            .padding(5, 28, 5, 10)
//            .height(50)
            .paddingLeft(18)
            .paddingTop(20)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(cryptoLabel)
        }
    }
    
    func configure(crypto: String) {
        cryptoLabel.text = crypto
        contentView.flex.layout()
    }
}

final class CurrencyPickerView: BaseFlexView {
    var pickerHolderView: UIView
    let picker: UITableView
    let pickerTitle: UILabel
    
    required init() {
        pickerHolderView = UIView()
        picker = UITableView()
        pickerTitle = UILabel(text: "Change Currency")
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        pickerTitle.font = applyFont(ofSize: 16, weight: .semibold)
        
        isOpaque = false
        backgroundColor = .clear
        pickerHolderView.layer.cornerRadius = 10
        picker.layer.cornerRadius = 10
    }
    
    override func configureConstraints() {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        let backgroundBlurView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        let visualEffectView = VisualEffectView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
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

