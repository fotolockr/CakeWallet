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

final class CurrencyPickerViewController: BlurredBaseViewController<CurrencyPickerView>, UITableViewDelegate, UITableViewDataSource {
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
        super.viewDidLoad()
        let receiveOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDismiss))
        contentView.backgroundView.addGestureRecognizer(receiveOnTapGesture)
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

struct PickerCellItem: CellItem {
    let item: Formatted
    let isSelected: Bool
    
    func setup(cell: CurrencyPickerTableCell) {
        cell.configure(crypto: item.formatted(), isSelected: isSelected)
    }
}

final class PickerView: BaseFlexView {
    var pickerHolderView: UIView
    let picker: UITableView
    let pickerTitle: UILabel
    let backgroundView: UIView
    
    required init() {
        pickerHolderView = UIView()
        picker = UITableView()
        pickerTitle = UILabel(text: "Change")
        backgroundView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        pickerTitle.font = applyFont(ofSize: 16, weight: .bold)
        pickerHolderView.layer.cornerRadius = 18
        pickerHolderView.layer.applySketchShadow(color: UIColor(red: 41, green: 23, blue: 77), alpha: 0.34, x: 0, y: 16, blur: 46, spread: -5)
        picker.layer.cornerRadius = 18
        picker.showsVerticalScrollIndicator = false
        backgroundView.isUserInteractionEnabled = true
    }
    
    override func configureConstraints() {
        pickerHolderView.flex
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(picker).minHeight(PickerTableCell.height)
        }
        
        rootFlexContainer.flex
            .justifyContent(.end)
            .alignItems(.center)
            .shrink(1)
            .backgroundColor(.clear)
            .padding(50, 25, 25, 25)
            .define{ flex in
                flex.addItem(backgroundView).backgroundColor(.clear).position(.absolute).left(0).top(0).size(frame.size)
                flex.addItem(pickerTitle).marginBottom(18)
                flex.addItem(pickerHolderView).paddingTop(15).paddingRight(18)
        }
    }
}


final class PickerViewController<Item>: BlurredBaseViewController<PickerView>, UITableViewDelegate, UITableViewDataSource where Item: (Formatted & Equatable) {
    let items: [Item]
    let selectedItem: Item
    var onPick: ((Item) -> Void)?
    var pickerTitle: String {
        get { return contentView.pickerTitle.text ?? "" }
        set { contentView.pickerTitle.text = newValue }
    }
    
    init(items: [Item], selectedItem: Item) {
        self.items = items
        self.selectedItem = selectedItem
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        contentView.picker.register(PickerTableCell.self, forCellReuseIdentifier: PickerTableCell.identifier)
        contentView.picker.dataSource = self
        contentView.picker.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let receiveOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDismiss))
        contentView.backgroundView.addGestureRecognizer(receiveOnTapGesture)
    }
    
    @objc
    func onDismiss() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableCell.identifier) as? PickerTableCell else {
            return UITableViewCell()
        }
        
        cell.configure(text: item.formatted(), isSelected: item == selectedItem)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PickerTableCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onPick?(item)
        dismiss(animated: true)
    }
}


