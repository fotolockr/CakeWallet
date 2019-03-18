import UIKit
import CakeWalletLib

extension CryptoCurrency: CellItem {
    func setup(cell: CurrencyPickerTableCell) {
        cell.configure(crypto: formatted())
    }
}

protocol CurrencyPickerDelegate: class {
    func onPicked(item: CryptoCurrency, pickerType: ExchangeCardType)
}

final class CurrencyPickerViewController: BaseViewController<CurrencyPickerView>, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CurrencyPickerDelegate?
    
    var type: ExchangeCardType
    let cryptos: [CryptoCurrency]
    private(set) var depositCrypto: CryptoCurrency

    override init() {
        type = .unknown
        cryptos = CryptoCurrency.all
        depositCrypto = .monero
        
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        contentView.picker.register(items: [CryptoCurrency.self])
        contentView.picker.dataSource = self
        contentView.picker.delegate = self
    }
    
    override func viewDidLoad() {
        let receiveOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDismiss))
        contentView.backgroundBlurView.addGestureRecognizer(receiveOnTapGesture)
    }
    
    @objc
    func onDismiss() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let crypto = cryptos[indexPath.row]
        return tableView.dequeueReusableCell(withItem: crypto, for: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let crypto = cryptos[indexPath.row]
        
        delegate?.onPicked(item: crypto, pickerType: type)
        dismiss(animated: true)
    }
}
