import UIKit
import CakeWalletLib
import CWMonero

struct TransactionDetailsCellItem: CellItem {
    let row: TransactionDetailsRows
    let value: String
    
    func setup(cell: TransactionDetailsCell) {
        cell.configure(title: row.string() + ":", value: value)
    }
}

enum TransactionDetailsRows: Stringify {
    case id, paymentId, date, amount, height, fee, exchangeID, transactionKey
    
    func string() -> String {
        switch self {
        case .id:
            return NSLocalizedString("transaction_id", comment: "")
        case .paymentId:
            return NSLocalizedString("Payment ID", comment: "")
        case .date:
            return NSLocalizedString("date", comment: "")
        case .amount:
            return NSLocalizedString("amount", comment: "")
        case .height:
            return NSLocalizedString("height", comment: "")
        case .fee:
            return  NSLocalizedString("fee", comment: "")
        case .exchangeID:
            return "Exchange ID"
        case .transactionKey:
            return "Transaction key"
        }
    }
}

final class TransactionDetailsViewController: BlurredBaseViewController<TransactionDetailsView>, UITableViewDataSource, UITableViewDelegate {
    private static let emptyPaymentId = "0000000000000000"
    private(set) var items: [TransactionDetailsCellItem]
    private let transactionDescription: TransactionDescription
    
    init(transactionDescription: TransactionDescription) {
        self.transactionDescription = transactionDescription
        items = []
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("transaction_details", comment: "")
        contentView.table.dataSource = self
        contentView.table.delegate = self
        contentView.table.register(items: [TransactionDetailsCellItem.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let doneButton = StandartButton(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 10, height: 10)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        update(transactionDescription: transactionDescription)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        //fixme: move to a class
        var rounded = false
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
//            cell.roundCorners([.topLeft, .topRight], radius: 20)
            rounded = true
        }
        
        if indexPath.row == items.count - 1 {
            cell.layer.masksToBounds = true
//            cell.contentView.roundCorners([.bottomLeft, .bottomRight], radius: 20)
            rounded = true
        }
        
        if !rounded {
            cell.layer.mask = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if (action == #selector(UIResponderStandardEditActions.copy(_:))) {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let item = items[indexPath.row]
        UIPasteboard.general.string = item.value
    }
    
    private func update(transactionDescription: TransactionDescription) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
        
        items = [TransactionDetailsCellItem(row: .id, value: transactionDescription.id)]
        
        if !transactionDescription.paymentId.isEmpty && transactionDescription.paymentId != TransactionDetailsViewController.emptyPaymentId {
            items.append(TransactionDetailsCellItem(row: .paymentId, value: transactionDescription.paymentId))
        }
        
        items.append(contentsOf: [
            TransactionDetailsCellItem(row: .date, value: dateFormatter.string(from: transactionDescription.date)),
            TransactionDetailsCellItem(row: .height, value: String(transactionDescription.height)),
            TransactionDetailsCellItem(row: .amount, value: transactionDescription.totalAmount.formatted())
            ])
        
        let fee = MoneroAmountParser.formatValue(transactionDescription.fee.value) ?? "0.0"

        if !fee.isEmpty {
            items.append(TransactionDetailsCellItem(row: .fee, value: fee))
        }
        
        if let tradeID = ExchangeTransactions.shared.getTradeID(by: transactionDescription.id) {
            items.append(TransactionDetailsCellItem(row: .exchangeID, value: tradeID))
        }
        
        if
            let transactionKey = getTransactionKey(for: transactionDescription.id),
            !transactionKey.isEmpty {
            items.append(TransactionDetailsCellItem(row: .transactionKey , value: transactionKey))
        }
        
        contentView.table.reloadData()
        contentView.rootFlexContainer.flex.layout(mode: .adjustHeight)
        contentView.table.isScrollEnabled = contentView.table.contentSize.height > contentView.table.frame.size.height
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
}
