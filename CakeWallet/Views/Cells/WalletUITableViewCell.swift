import UIKit
import FlexLayout
import PinLayout
import CakeWalletLib

final class WalletUITableViewCell: FlexCell {
    let nameLabel: UILabel
    var showSeedButton: UIButton?
    var showKeysButton: UIButton?
    var loadButton: UIButton?
    var onLoadHandler: ((WalletIndex) -> Void)?
    var onShowSeedHandler: ((WalletIndex) -> Void)?
    var onShowKeysHandler: ((WalletIndex) -> Void)?
    private(set) var optionsContainer: UIView?
    private(set) var isOptionsShown: Bool
    private var wallet: WalletIndex?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel()
        isOptionsShown = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(wallet: WalletIndex, isCurrent: Bool) {
        self.wallet = wallet
        nameLabel.text = wallet.name
        backgroundColor = .white
        
        if isCurrent {
            nameLabel.textColor = .vividBlue
            accessoryType = .checkmark
        } else {
            nameLabel.textColor = Theme.current.text
            accessoryType = .none
        }
        
        nameLabel.flex.markDirty()
        contentView.flex.markDirty()
        layout()
    }
    
    override func configureView() {
        super.configureView()
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        contentView.flex.padding(10, 10, 15, 0).define { flex in
            flex.addItem(nameLabel).marginTop(10)
        }
    }
    
    func showOptions() {
        guard !isOptionsShown else {
            return
        }
        
        addOptionsContainer()
        isOptionsShown = true
        optionsContainer?.flex.markDirty()
        contentView.flex.markDirty()
        layout()
    }
    
    func hideOptions() {
        guard isOptionsShown else {
            return
        }
        
        removeOptionsContainer()
        isOptionsShown = false
        optionsContainer?.flex.markDirty()
        contentView.flex.markDirty()
        layout()
    }
    
    func switchOptions() {
        isOptionsShown = !isOptionsShown
        
        if isOptionsShown {
            addOptionsContainer()
        } else {
            removeOptionsContainer()
        }
        
        optionsContainer?.flex.markDirty()
        contentView.flex.markDirty()
        layout()
    }
    
    private func addOptionsContainer() {
        guard optionsContainer == nil else {
            return
        }
        
        let view = UIView()
        let _showSeedButton = SecondaryButton(title: "show_seed", fontSize: 12)
        let _showKeysButton = SecondaryButton(title: "show_keys", fontSize: 12)
        let _loadButton = PrimaryButton(title: "Load", fontSize: 12)
        showSeedButton = _showSeedButton
        showKeysButton = _showKeysButton
        loadButton = _loadButton
        _showKeysButton.addTarget(self, action: #selector(onShowKeysAction), for: .touchUpInside)
        _showSeedButton.addTarget(self, action: #selector(onShowSeedAction), for: .touchUpInside)
        _loadButton.addTarget(self, action: #selector(onLoadAction), for: .touchUpInside)
        optionsContainer = view
        optionsContainer?.flex.direction(.row).height(40).marginTop(25).define { flex in
            flex.addItem(_showSeedButton).width(80).height(40)
            flex.addItem(_showKeysButton).width(80).height(40).marginLeft(10)
            flex.addItem(_loadButton).width(80).height(40).marginLeft(10)
        }
        contentView.flex.addItem(view)
    }
    
    private func removeOptionsContainer() {
        showKeysButton?.removeTarget(self, action: #selector(onShowKeysAction), for: .touchUpInside)
        showSeedButton?.removeTarget(self, action: #selector(onShowSeedAction), for: .touchUpInside)
        loadButton?.removeTarget(self, action: #selector(onLoadAction), for: .touchUpInside)
        optionsContainer?.removeFromSuperview()
        optionsContainer = nil
    }
    
    @objc
    private func onLoadAction() {
        if let wallet = wallet {
            onLoadHandler?(wallet)
        }
    }
    
    @objc
    private func onShowSeedAction() {
        if let wallet = wallet {
            onShowSeedHandler?(wallet)
        }
    }
    
    @objc
    private func onShowKeysAction() {
        if let wallet = wallet {
            onShowKeysHandler?(wallet)
        }
    }
}
