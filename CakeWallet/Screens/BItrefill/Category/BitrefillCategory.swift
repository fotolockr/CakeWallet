import UIKit
import FlexLayout


public enum BitrefillCategoryType: String {
    case refill, games, data, other, travel, lightning, voip, ecommerce, food, pin, dth
    
    var categoryName: String {
        switch self {
        case .refill:
            return "Prepaid phones"
        case .games:
            return "Games"
        case .data:
            return "Data bundles"
        case .other:
            return "Other"
        case .travel:
            return "Travel"
        case .lightning:
            return "Lightning"
        case .voip:
            return "VoIP"
        case .ecommerce:
            return "Ecommerce"
        case .food:
            return "Food"
        case .pin:
            return "Phone refill vouchers / PINs"
        case .dth:
            return "Digital Television (DTH)"
        }
    }
    
    var categoryIcon: UIImage {
        switch self {
        case .refill:
            return UIImage(named: "bitrefill_mobile_icon")!
        case .games:
            return UIImage(named: "bitrefill_games_icon")!
        case .data:
            return UIImage(named: "bitrefill_data_icon")!
        case .other:
            return UIImage(named: "bitrefill_other_icon")!
        case .travel:
            return UIImage(named: "bitrefill_travel_icon")!
        case .lightning:
            return UIImage(named: "bitrefill_lightning_icon")!
        case .voip:
            return UIImage(named: "bitrefill_voip_icon")!
        case .ecommerce:
            return UIImage(named: "bitrefill_ecommerce_icon")!
        case .food:
            return UIImage(named: "bitrefill_food_icon")!
        case .pin:
            return UIImage(named: "bitrefill_mobile_icon")!
        case .dth:
            return UIImage(named: "bitrefill_data_icon")!
        }
    }
    
    var categoryOrder: Int {
        switch self {
        case .refill:
            return 1
        case .data:
            return 2
        case .pin:
            return 3
        case .ecommerce:
            return 4
        case .games:
            return 5
        case .travel:
            return 6
        case .voip:
            return 7
        case .food:
            return 8
        case .lightning:
            return 9
        case .other:
            return 10
        case .dth:
            return 11
        }
    }
}


final class BitrefillCategoryTableCell: FlexCell {
    let contentHolder = UIView()
    let name = UILabel()
    let imgView = UIImageView(image: nil)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(name: String, icon: UIImage) {
        self.name.text = name
        
        self.name.flex.markDirty()
        contentView.flex.layout()
        
        imgView.image = icon
    }
    
    override func configureView() {
        super.configureView()
        
        name.font = applyFont(ofSize: 17)
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        contentHolder.flex
            .direction(.row)
            .justifyContent(.start)
            .alignItems(.center)
            .width(100%)
            .height(62)
            .paddingHorizontal(25)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(imgView).width(35).height(35)
                flex.addItem(name).marginLeft(30)
        }
        
        contentView.flex
            .width(100%)
            .height(80)
            .backgroundColor(Theme.current.container.background)
            .define{ flex in
                flex.addItem(contentHolder)
        }
    }
}


struct BitrefillCategory {
    let name: String
    let type: BitrefillCategoryType
    let icon: UIImage
    
    init(name: String, type: BitrefillCategoryType, icon: UIImage) {
        self.name = name
        self.type = type
        self.icon = icon
    }
}

extension BitrefillCategory: CellItem {
    func setup(cell: BitrefillCategoryTableCell) {
        cell.configure(name: name, icon: icon)
    }
}
