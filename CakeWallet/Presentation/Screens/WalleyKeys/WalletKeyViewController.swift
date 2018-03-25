//
//  WalletKeyViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 15.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class WalletKeysUITableViewCell: UITableViewCell {
    let titleLabel: UILabel
    let valueLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(font: .avenirNextDemiBold(size: 15))
        valueLabel = UILabel(font: .avenirNextMedium(size: 12))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        addSubview(titleLabel)
        addSubview(valueLabel)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
            make.width.greaterThanOrEqualTo(50)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        needsUpdateConstraints()
    }
}


final class WalletKeyViewController: BaseViewController<WalletKeyView>, UITableViewDelegate, UITableViewDataSource {
    enum Row: Int, Stringify {
        case publicView, secretView, publicSpend, secretSpend
        
        func stringify() -> String {
            let str: String
            
            switch self {
            case .publicView:
                str = "Public view"
            case .secretView:
                str = "Secret view"
            case .publicSpend:
                str = "Public spend"
            case .secretSpend:
                str = "Secret spend"
            }
            
            return str
        }
    }
    
    private let viewKey: WalletKey
    private let spendKey: WalletKey
    private let name: String
    private var rows: [Row: String]
    
    convenience init(wallet: WalletProtocol) {
        self.init(name: wallet.name, viewKey: wallet.viewKey, spendKey: wallet.spendKey)
    }
    
    init(name: String, viewKey: WalletKey, spendKey: WalletKey) {
        self.name = name
        self.viewKey = viewKey
        self.spendKey = spendKey
        rows = [:]
        super.init()
    }
    
    override func configureBinds() {
        title = "Keys"
        contentView.table.register(
            WalletKeysUITableViewCell.self,
            forCellReuseIdentifier: WalletKeysUITableViewCell.identifier)
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.nameLabel.text = name
                
        rows[.publicView] = viewKey.pub
        rows[.secretView] = viewKey.sec
        rows[.publicSpend] = spendKey.pub
        rows[.secretSpend] = spendKey.sec
        
        let closeButton = UIBarButtonItem(
            image: UIImage.fontAwesomeIcon(name: .close, textColor: .gray, size: CGSize(width: 36, height: 36)),
            style: .done,
            target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletKeysUITableViewCell", for: indexPath) as? WalletKeysUITableViewCell,
            let row = Row(rawValue: indexPath.row),
            let value = rows[row] else {
                return UITableViewCell()
        }
        
        cell.configure(title: row.stringify(), value: value)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            copyValueFromItem(withIndexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    private func copyValueFromItem(withIndexPath indexPath: IndexPath) {
        guard
            let row = Row(rawValue: indexPath.row),
            let value = rows[row] else {
                return
        }
        
        UIPasteboard.general.string  = value
    }
}
