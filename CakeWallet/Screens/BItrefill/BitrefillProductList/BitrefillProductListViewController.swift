import UIKit

struct Product {
    let title: String
    let image: UIImageView
    
    init(title: String, image: UIImageView) {
        self.title = title
        self.image = image
    }
}

final class BitrefillProductListViewController: BaseViewController<BitrefillProductListView>, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var items = [
        BitrefillTableItem(title: "Amazon.com", icon: UIImage(named: "tmp_bitrefill_amazon_logo")!),
        BitrefillTableItem(title: "eBay", icon: UIImage(named: "tmp_bitrefill_ebay_logo")!),
        BitrefillTableItem(title: "Walmart", icon: UIImage(named: "tmp_bitrefill_walmart_logo")!),
        BitrefillTableItem(title: "Netflix", icon: UIImage(named: "tmp_bitrefill_netflix_logo")!),
        BitrefillTableItem(title: "Best Buy", icon: UIImage(named: "tmp_bitrefill_bestbuy_logo")!),
        BitrefillTableItem(title: "Nike", icon: UIImage(named: "tmp_bitrefill_nike_logo")!),
        BitrefillTableItem(title: "Adidas", icon: UIImage(named: "tmp_bitrefill_adidas_logo")!),
    ]
    
    init(bitrefillFlow: BitrefillFlow?) {
        self.bitrefillFlow = bitrefillFlow
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        title = "Product"
        
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
        let orderVC = BitrefillOrderViewController(product: items[indexPath.row])
        
        bitrefillFlow?.change(viewController: orderVC)
    }
}

