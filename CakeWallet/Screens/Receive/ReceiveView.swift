import UIKit
import FlexLayout


final class ReceiveView: BaseFlexView {
    let qrCodeWrapper: UIView
    let qrImage: UIImageView
    let addressLabel: UILabel
    let copyAddressButton: UIButton
    let amountTextField: CWTextField
    let topSectionWrapper: UIView
    let table: UITableView
    let subaddressesHeaderView: UIView
    let subaddressesLabel: UILabel
    let addSubaddressButton: UIButton
    let headerView: UIView
    
    required init() {
        qrImage = UIImageView()
        addressLabel = UILabel(fontSize: 14)
        copyAddressButton = SecondaryButton(title: NSLocalizedString("copy_address", comment: ""))
        amountTextField = CWTextField(placeholder: NSLocalizedString("amount", comment: ""), fontSize: 15)
        topSectionWrapper = UIView()
        qrCodeWrapper = UIView()
        table = UITableView()
        subaddressesHeaderView = UIView()
        subaddressesLabel = UILabel(fontSize: 16)
        addSubaddressButton = UIButton()
        headerView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        copyAddressButton.backgroundColor = UIColor.turquoiseBlue
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        addressLabel.font = applyFont(ofSize: 14)
        amountTextField.keyboardType = .decimalPad
        addSubaddressButton.setImage(UIImage(named: "add_icon_purple"), for: .normal)
        subaddressesLabel.text = "Subaddresses"
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        subaddressesHeaderView.flex
            .backgroundColor(.lightCream)
            .justifyContent(.center)
            .paddingLeft(20)
            .define { flex in
                flex.addItem(subaddressesLabel).height(100%).width(100%)
                flex.addItem(addSubaddressButton).width(33).height(33).position(.absolute).right(20)
        }
        
        headerView.flex.define { flex in
            flex.addItem(topSectionWrapper)
            flex.addItem(subaddressesHeaderView).height(56).marginTop(10).width(100%)
        }
        
        topSectionWrapper.flex
            .alignItems(.center)
            .width(100%)
            .paddingHorizontal(adaptiveLayout.getSize(forLarge: 50, forBig: 35, defaultSize: 30))
            .paddingVertical(20)
            .define {flex in
                flex.addItem(qrCodeWrapper).alignItems(.center).width(100%).addItem(qrImage).size(CGSize(width: 150, height: 150))
                flex.addItem(addressLabel).marginTop(15)
                flex.addItem(amountTextField).marginTop(20).height(45).width(100%)
        }
        
        rootFlexContainer.flex
            .backgroundColor(.clear)
            .define { flex in
                flex.addItem(table).width(100%).height(100%)
        }
        
        table.tableHeaderView = headerView
    }
}
