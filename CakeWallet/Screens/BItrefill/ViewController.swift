import UIKit
import FlexLayout


final class BitrefillCategoryTableCell: FlexCell {
    let contentHolder = UIView()
    let title = UILabel()
    var icon = UIImage()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(title: String, icon: UIImage) {
        self.title.text = title
        self.icon = icon
        self.title.flex.markDirty()
        contentView.flex.layout()
    }
    
    override func configureView() {
        super.configureView()
        
        title.font = applyFont(ofSize: 16)
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        contentHolder.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .width(100%)
            .height(60)
            .paddingHorizontal(10)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(UIImageView(image: icon)).width(30).height(30)
                flex.addItem(title)
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
    let title: String
    let icon: UIImage
    
    init(title: String, icon: UIImage) {
        self.title = title
        self.icon = icon
    }
}

extension BitrefillCategory: CellItem {
    func setup(cell: BitrefillCategoryTableCell) {
        cell.configure(title: title, icon: icon)
    }
}


final class BitrefillBaseViewController: BaseViewController<BitrefillBaseView>, UITableViewDelegate, UITableViewDataSource {
    var items = [
        BitrefillCategory(title: "Prepaid phones", icon: UIImage(named: "bitrefill_mobile_icon")!),
//        BitrefillCategory(title: "Data bundles", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Phone refill vouchers / PINs", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Ecommerce", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Games", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Travel", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "VoIP", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Food", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Other products", iconName: "bitrefill_mobile_icon"),
//        BitrefillCategory(title: "Digital Television (DTH)", iconName: "bitrefill_mobile_icon")
    ]
    
    override init() {
        super.init()
        
        tabBarItem = UITabBarItem(
            title: "Bitrefill",
            image: UIImage(named: "bitrefill_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bitrefill_selected_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Bitrefill"
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [BitrefillCategory.self])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
