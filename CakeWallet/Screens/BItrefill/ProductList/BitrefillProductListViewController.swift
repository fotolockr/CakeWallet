import UIKit


final class BitrefillProductListViewController: BaseViewController<BitrefillProductListView>, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var products = [BitrefillProduct]()
    
    init(bitrefillFlow: BitrefillFlow?, products: [BitrefillProduct]) {
        self.bitrefillFlow = bitrefillFlow
        self.products = products
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Product"
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [BitrefillProduct.self])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = products[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // TODO: don't create order yet
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.row]
        let order = BitrefillOrder(
            name: selectedProduct.name,
            operatorSlug: selectedProduct.slug,
            isRanged: selectedProduct.isRanged,
            recipientType: selectedProduct.recipientType,
            currency: selectedProduct.currency
        )
        
        bitrefillFlow?.change(route: .order(order))
    }
}

