import UIKit
import FlexLayout


final class BitrefillTableCell: FlexCell {
    let contentHolder = UIView()
    let title = UILabel()
    let imgView = UIImageView(image: nil)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(title: String, icon: UIImage) {
        self.title.text = title
        
        self.title.flex.markDirty()
        contentView.flex.layout()
        
        imgView.image = icon
    }
    
    override func configureView() {
        super.configureView()
        
        title.font = applyFont(ofSize: 17)
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
                flex.addItem(title).marginLeft(30)
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


struct BitrefillTableItem {
    let title: String
    let icon: UIImage
    
    init(title: String, icon: UIImage) {
        self.title = title
        self.icon = icon
    }
}

extension BitrefillTableItem: CellItem {
    func setup(cell: BitrefillTableCell) {
        cell.configure(title: title, icon: icon)
    }
}


final class BitrefillBaseViewController: BaseViewController<BitrefillBaseView>, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var items = [
        BitrefillTableItem(title: "Prepaid phones", icon: UIImage(named: "bitrefill_mobile_icon")!),
        BitrefillTableItem(title: "Data bundles", icon: UIImage(named: "bitrefill_data_icon")!),
        BitrefillTableItem(title: "Phone refill vouchers / PINs", icon: UIImage(named: "bitrefill_mobile_icon")!),
        BitrefillTableItem(title: "Ecommerce", icon: UIImage(named: "bitrefill_ecommerce_icon")!),
        BitrefillTableItem(title: "Games", icon: UIImage(named: "bitrefill_games_icon")!),
        BitrefillTableItem(title: "Travel", icon: UIImage(named: "bitrefill_travel_icon")!),
        BitrefillTableItem(title: "VoIP", icon: UIImage(named: "bitrefill_voip_icon")!),
        BitrefillTableItem(title: "Food", icon: UIImage(named: "bitrefill_food_icon")!)
    ]
    
    init(bitrefillFlow: BitrefillFlow?) {
        self.bitrefillFlow = bitrefillFlow
        super.init()
        tabBarItem = UITabBarItem(
            title: "Bitrefill",
            image: UIImage(named: "bitrefill_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bitrefill_selected_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Category"
        tabBarItem.title = "Bitrefill" // Fixme: Hardcoded and duplicated value.
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [BitrefillTableItem.self])
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bitrefillFlow?.change(route: .productList)
    }
}
