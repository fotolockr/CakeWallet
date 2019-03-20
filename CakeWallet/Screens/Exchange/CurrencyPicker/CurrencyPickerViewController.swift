import UIKit
import CakeWalletLib

protocol CurrencyPickerDelegate: class {
    func onPicked(item: CryptoCurrency, pickerType: ExchangeCardType)
}

struct CryptoCurrencyCellItem: CellItem {
    let currency: CryptoCurrency
    let isSelected: Bool
    
    func setup(cell: CurrencyPickerTableCell) {
        cell.configure(crypto: currency.formatted(), isSelected: isSelected)
    }
}

final class CurrencyPickerViewController: BaseViewController<CurrencyPickerView>, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CurrencyPickerDelegate?
    
    var type: ExchangeCardType
    let cryptos: [CryptoCurrencyCellItem]
    private(set) var depositCrypto: CryptoCurrency
    
    init(selectedItem: CryptoCurrency) {
        type = .unknown
        cryptos = CryptoCurrency.all.map { CryptoCurrencyCellItem(currency: $0, isSelected: $0 == selectedItem) }
        depositCrypto = .monero
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        contentView.picker.register(items: [CryptoCurrencyCellItem.self])
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let crypto = cryptos[indexPath.row].currency
        delegate?.onPicked(item: crypto, pickerType: type)
        dismiss(animated: true)
    }
}
